
define virt::services {
	
	$iface_one_20 = "%network[:'pod_one_20'][:interface]%" 
	$iface_one_10 = "%network[:'pod_one_10'][:interface]%" 
	$iface_ceph_20 = "%network[:'pod_ceph_20'][:interface]%" 
	$vlan_iface_one_20 = "${iface_one_20}.20"
	$vlan_iface_one_10 = "${iface_one_10}.10"
	$vlan_address_one_20 = "%network[:'pod_one_20'][:ipaddress]%/24"
	$vlan_address_one_10 = "%network[:'pod_one_10'][:ipaddress]%/24"
	$vlan_iface_ceph_20 = "${iface_ceph_20}.20"
	$vlan_address_ceph_20 = "%network[:'pod_ceph_20'][:ipaddress]%/24"

	$env = $facts['env_vars']

	$guest_vlan_one_20 = net::create_vlan({
			'Ipaddress' => $vlan_address_one_20,
			'Vid'	    => 20,
			'Iface'     => $iface_one_20,
			'VlanIface' => $vlan_iface_one_20,
	}) 

	$guest_vlan_one_10 = net::create_vlan({
			'Ipaddress' => $vlan_address_one_10,
			'Vid'	    => 10,
			'Iface'     => $iface_one_10,
			'VlanIface' => $vlan_iface_one_10,
	}) 

	$guest_vlan_ceph_20 = net::create_vlan({
			'Ipaddress' => $vlan_address_ceph_20,
			'Vid'	    => 20,
			'Iface'     => $iface_ceph_20,
			'VlanIface' => $vlan_iface_ceph_20,
	})
}
