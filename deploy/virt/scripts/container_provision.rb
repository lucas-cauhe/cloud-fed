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

#def podman_command(container_name, cmd)
#  #
#  # Connect to Podman API
#  #
#  client = NetX::HTTPUnix.new("unix:////run/podman/podman.sock")
#  create_exec_req = Net::HTTP::Post.new("http://d/v5.0.0/libpod/containers/#{container_name}/exec")
#  start_exec_req = Net::HTTP::Post.new("http://d/v5.0.0/libpod/containers/#{container_name}/exec")
#  req_body = {
#    "AttachStderr" => true,
#    "AttachStdout" => true,
#    "Tty" => false,
#    "Cmd" => cmd,
#  }
#  create_exec_req["Content-Type"] = "application/json"
#  response = client.request(create_exec_req, body = req_body)
#  exec_id = JSON.parse(response.body)["Id"]
#
#  start_body = {
#    "Detach" => false,
#    "Tty" => false,
#  }
#  client.request(start_exec_req, body = start_body)
#end

def get_container_addressed_interface(cname, address)
  output = `podman exec #{cname} ip a show to #{address} | cut -d ':' -f2 | head -n1 | cut -d '@' -f1`
  output.gsub("\n", "").strip!
end

def network_layout(container_name)
  network_inspection_cmd = `podman inspect --format='{{json .NetworkSettings.Networks }}' #{container_name}`.gsub("\n", "")

  if network_inspection_cmd == ""
    Puppet.notice("No container with provided name exists")
  end

  data = JSON.parse(network_inspection_cmd, { symbolize_names: true })
  result = data.map { |k, v| [k, { :ipaddress => v[:IPAddress], :interface => get_container_addressed_interface(container_name, v[:IPAddress]) }] }.to_h
  result
end

def network_layout_iface(container_name, network_name)
  data = network_layout(container_name)
  data.find { |k, v| k == network_name }
end

def scan_podman_services
  network_scan = `podman ps --format '{{.Names}}'`.lines.map { |container_name|
    container_name_ = container_name.gsub("\n", "")
    [container_name_, { :network => network_layout(container_name_) }]
  }.to_h
end

def deployment_layout
  {
    :virt => {
      :services => scan_podman_services,
    },
  }
end

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

def process_file_entry(cname, file_desc)
  file_content = produce_file_content(cname, file_desc)
  file_dest = "#{cname}:#{file_desc[:path]}"
  File.write("/tmp/tmp_file_entry", file_content)
  `podman cp /tmp/tmp_file_entry #{file_dest}`
  `podman exec #{cname} chown #{file_desc[:owner]} #{file_desc[:path]}` if file_desc[:owner]
  File.delete("/tmp/tmp_file_entry")
end

def map_var_subs(entry_map, container_namespace)
  return var_subs(entry_map, container_namespace) unless entry_map.respond_to?(:map)
  entry_map.map { |k, v| [k.to_sym, map_var_subs(v, container_namespace)] }.to_h
end

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

def generate_namespace(cname)
  container_inspection = JSON.parse(`sudo podman inspect --format json #{cname}`.gsub("\n", ""))[0]
  {
    "network" => network_layout(cname),
    "deployment" => deployment_layout,
    "devices" => devices_layout(cname, container_inspection),
  }
end

container_namespace = generate_namespace(params["container_name"])

params["plan"].each { |action_type|
  action_type["actions"].each do |action|
    next unless action_type["onlyif"]
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
