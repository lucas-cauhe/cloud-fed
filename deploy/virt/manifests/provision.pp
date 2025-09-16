

class virt::provision {

	$iface_one_20 = "%network[:'pod_one_20'][:interface]%" 
	$iface_one_10 = "%network[:'pod_one_10'][:interface]%" 
	$iface_ceph_20 = "%network[:'pod_ceph_20'][:interface]%" 
	$vlan_iface_one_20 = "${iface_one_20}.20"
	$vlan_iface_one_10 = "${iface_one_10}.10"
	$vlan_address_one_20 = "%network[:'pod_one_20'][:ipaddress]%/24"
	$vlan_address_one_10 = "%network[:'pod_one_10'][:ipaddress]%/24"
	$vlan_iface_ceph_20 = "${iface_ceph_20}.20"
	$vlan_address_ceph_20 = "%network[:'pod_ceph_20'][:ipaddress]%/24"


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
	
	$sql_query_base = "mariadb -u root -p${facts['env_vars']['MARIADB_ROOT_PASSWD']} -e \\\""
	$sql_query_end = ";\\\""

	$db_setup = [
		"$sql_query_base CREATE USER oneadmin_20@localhost IDENTIFIED BY 'oneadmin_20' $sql_query_end",
		"$sql_query_base CREATE USER oneadmin_10@localhost IDENTIFIED BY 'oneadmin_10'$sql_query_end",
		"$sql_query_base CREATE DATABASE opennebula_20$sql_query_end",
		"$sql_query_base CREATE DATABASE opennebula_10$sql_query_end",
		"$sql_query_base GRANT ALL PRIVILEGES ON opennebula_20.* TO 'oneadmin_20'@'localhost'$sql_query_end",
		"$sql_query_base GRANT ALL PRIVILEGES ON opennebula_10.* TO 'oneadmin_10'@'localhost'$sql_query_end",
	]


	virt::container_provision { "one_20_provision": 
		container_name => "one_20",
		guest => $guest_vlan_one_20	
	}

	virt::container_provision { "one_10_provision": 
		container_name => "one_10",
		guest => $guest_vlan_one_10	
	}

	virt::container_provision { "ceph_20_provision": 
		container_name => "ceph_20",
		guest => $guest_vlan_ceph_20, 
	}

	virt::container_provision { "gateway_provision_vlan_20": 
		container_name => "gateway",
		guest => $guest_vlan_one_20, 
		container => [
			"podman network connect podman gateway",	
			"podman network connect pod_one_10 gateway",	
		]
	} ->
	virt::container_provision { "gateway_provision_vlan_10": 
		container_name => "gateway",
		guest => $guest_vlan_one_10, 
	}

	virt::container_provision { "one_db_provision":
		container_name => "one_db",
		guest => $guest_vlan_one_10 + $guest_vlan_one_20 + $db_setup,
		container => [
			"podman network connect pod_one_20 one_db"
		]
	}
}
