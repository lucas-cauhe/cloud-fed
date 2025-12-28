
Puppet::Functions.create_function(:'net::create_vlan') do 
  dispatch :_create_vlan do
    param 'Hash', :vlan_info
  end

  def _create_vlan(vlan_info)
    [
      "%reload% ip link add link #{vlan_info['Iface']} name #{vlan_info['VlanIface']} type vlan id #{vlan_info['Vid']}",
      "ip a add #{vlan_info['Ipaddress']} dev #{vlan_info['VlanIface']}",
      "ip link set dev #{vlan_info['VlanIface']} up",
      "ip a del #{vlan_info['Ipaddress']} dev #{vlan_info['Iface']}"
    ]
  end
end
