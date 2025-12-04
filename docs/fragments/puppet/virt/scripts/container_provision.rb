#!/usr/bin/env ruby

require "json"
require "open3"
#require 'net_http_unix'

args_path = ARGV[0]
magic = ARGV[1]
command_entries = ["container", "guest"]

# Load json
exit 0 unless File.exist?(args_path)

file = open(args_path)
parsed = file.read
params = JSON.parse(parsed)

exit 0 if `podman exec #{params["container_name"]} ls -1 /var/#{magic} 2>/dev/null` == "/var/#{magic}\n"
`podman exec #{params["container_name"]} touch /var/#{magic}`

#
# Función que obtiene el nombre de la interfaz que tiene asignada la dirección IP _address_ en el contenedor _cname_.
#
def get_container_addressed_interface(cname, address)
  output = `podman exec #{cname} ip a show to #{address} | cut -d ':' -f2 | head -n1 | cut -d '@' -f1`
  output.gsub("\n", "").strip!
end

#
# Función que devuelve un diccionario con las direcciones IP asigandas a cada interfaz en el contenedor _container_name_
#
def network_layout(container_name)
  network_inspection_cmd = `podman inspect --format='{{json .NetworkSettings.Networks }}' #{container_name}`.gsub("\n", "")

  if network_inspection_cmd == ""
    Puppet.notice("No container with provided name exists")
  end

  data = JSON.parse(network_inspection_cmd, { symbolize_names: true })
  result = data.map { |k, v| [k, { :ipaddress => v[:IPAddress], :interface => get_container_addressed_interface(container_name, v[:IPAddress]) }] }.to_h
  result
end

#
# Función que obtiene la información de la interfaz de red local del contenedor
# _container_name_ que está conectada a la red de contenedores _network_name_.
#
def network_layout_iface(container_name, network_name)
  data = network_layout(container_name)
  data.find { |k, v| k == network_name }
end

#
# Función que devuelve la información relativa a la red de todos los contenedores desplegados en un host.
#
def scan_podman_services
  network_scan = `podman ps --format '{{.Names}}'`.lines.map { |container_name|
    container_name_ = container_name.gsub("\n", "")
    [container_name_, { :network => network_layout(container_name_) }]
  }.to_h
end

#
# Función que devuelve la información relativa a todos los contenedores desplegados en un host.
#
def deployment_layout
  {
    :virt => {
      :services => scan_podman_services,
    },
  }
end

#
# Función que sustituye todos las variables de la API ofrecida por sus valores reales.
#
def var_subs(src, ns)
  src.gsub(/%(\w+)(\[[^%]+\])%/) do |match|
    begin
      eval("ns['#{$1}']#{$2}")
    rescue NoMethodError
      puts ns
      puts "EVALUATING ns['#{$1}']#{$2}"
    end
  end
end

def fe_mode(file_desc)
  if file_desc[:replace]
    :fe_replace
  elsif file_desc[:content]
    :fe_content
  elsif file_desc[:append]
    :fe_append
  else
    :none
  end
end

#
# Función de utilidad para modificar, añadir o crear un fichero en el contenedor con el contenido deseado
#
def produce_file_content(cname, file_desc)
  case fe_mode(file_desc)
  when :fe_replace
    file_content = `podman exec #{cname} cat #{file_desc[:path]}`
    file_content.gsub! file_desc[:replace][:src].gsub(/\t/, ""), file_desc[:replace][:dest]
    file_content
  when :fe_content
    file_desc[:content]
  when :fe_append
    file_content = `podman exec #{cname} cat #{file_desc[:path]}`.gsub('\n', "")
    file_content + file_desc[:append]
  else
    ""
  end
end

#
# Función intermedia para modificar un fichero en un contenedor
#
def process_file_entry(cname, file_desc)
  file_content = produce_file_content(cname, file_desc)
  file_dest = "#{cname}:#{file_desc[:path]}"
  File.write("/tmp/tmp_file_entry", file_content)
  `podman cp /tmp/tmp_file_entry #{file_dest}`
  `podman exec #{cname} chown #{file_desc[:owner]} #{file_desc[:path]}` if file_desc[:owner]
  File.delete("/tmp/tmp_file_entry")
end

#
# Función que sustituye todas las variables encontradas en todo el plan de despliegue.
#
def map_var_subs(entry_map, container_namespace)
  return var_subs(entry_map, container_namespace) unless entry_map.respond_to?(:map)
  entry_map.map { |k, v| [k.to_sym, map_var_subs(v, container_namespace)] }.to_h
end

#
# Función que devuelve el estado de los dispositivos que ve un contenedor.
#
def devices_layout(container_name, inspect)
  container_args = inspect["Config"]["CreateCommand"]
  mapped_devices = []
  (0..container_args.length - 1).each do |i|
    mapped_devices.append(container_args[i + 1]) if container_args[i] == "--device"
  end
  # Handles full dereference for symlinks (lvm dev to device mapper dev)
  host_mapped = mapped_devices.map { |device| [File.realpath(device), device] }.to_h
  devices = inspect["HostConfig"]["Devices"]
  devices.map { |device| [host_mapped[device["PathOnHost"]], device["PathInContainer"]] }.to_h
end

#
# Función que genera un diccionario con el estado de red, almacenamiento y despliegue.
#
def generate_namespace(cname)
  container_inspection = JSON.parse(`sudo podman inspect --format json #{cname}`.gsub("\n", ""))[0]
  {
    "network" => network_layout(cname),
    "deployment" => deployment_layout,
    "devices" => devices_layout(cname, container_inspection),
  }
end

container_namespace = generate_namespace(params["container_name"])

#
# Lógica que ejecuta el plan especificado
#
params["plan"].each { |action_type|
  action_type["actions"].each do |action|
    #
    # Comprueba si debe ejecutar la siguiente acción
    #
    next unless action_type["onlyif"]

    #
    # Comprueba si tiene que recalcular el _container_namespace_.
    #
    if command_entries.include? action_type["type"]
      reloadable = false
      expecting = false
      expected_output = ""
      case action.split.first
      when "%reload%"
        reloadable = true
        action = action.split[1..-1].join(" ")
        container_namespace = generate_namespace(params["container_name"])
      when /%expect\[.*/
        expecting = true
        _, raw_expecting, action = action.split(/(%expect\[.*\]%)/)
        expected_output = raw_expecting[/\[.*\]/].delete("[]")
      end

      #
      # Ejecuta un mismo comando hasta que se complete un estado esperado o sea de una sola ejecución.
      #
      loop do
        subs_entry = var_subs(action, container_namespace)
        stdout, stderr, status = Open3.capture3(subs_entry)
        if stderr != "" && status && status != 0
          puts "COMMAND #{subs_entry} for container #{params["container_name"]} failed with status #{status}: #{stderr}"
          exit 1
        end

        if expecting && !stdout.include?(expected_output)
          puts "WAITING ON COMMAND: #{action} to meet #{expected_output}"
          sleep 1
        else
          break
        end
      end
    else
      # Its a file description
      next unless action != {}
      subs_entry = map_var_subs(action, container_namespace)
      process_file_entry(params["container_name"], subs_entry)
    end
  end
}

File.delete(args_path)
