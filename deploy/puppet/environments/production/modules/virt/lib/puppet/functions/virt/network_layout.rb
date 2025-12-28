require 'json'

Puppet::Functions.create_function(:'virt::network_layout') do 
  dispatch :_network_layout do 
    param 'String', :container_name
  end

  dispatch :_network_layout_iface do 
    param 'String', :container_name
    param 'String', :network_name
  end

  def _network_layout(container_name)
    network_inspection_cmd = `sudo podman inspect --format='{{json .NetworkSettings.Networks }}' #{container_name}`.gsub("\n", "") 
    if network_inspection_cmd == "" 
      Puppet.notice("No container with provided name exists")
    end
    
    data = JSON.parse(network_inspection_cmd, {symbolize_names:true})
    result = data.map {| k, v | [k, {:ipaddress => v[:IPAddress], :interface => get_container_addressed_interface(container_name, v[:IPAddress])}] }.to_h
    result
  end

  def _network_layout_iface(container_name, network_name)
    data = _network_layout(container_name)
    data.find { |k, v| k == network_name }
  end

  def get_container_addressed_interface(cname, address)
    output = `sudo podman exec #{cname} ip a show to #{address} | cut -d ':' -f2 | head -n1 | cut -d '@' -f1`
    output.gsub("\n", "").strip!
  end
end
