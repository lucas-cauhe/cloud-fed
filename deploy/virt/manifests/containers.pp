class virt::containers {
	$deployment_units = ['10', '20']
	$iface_one_20 = "%network[:'pod_one_20'][:interface]%"
	$iface_one_10 = "%network[:'pod_one_10'][:interface]%"
	$iface_ceph_20 = "%network[:'pod_ceph_20'][:interface]%"
	$iface_ceph_10 = "%network[:'pod_ceph_10'][:interface]%"
	$iface_stor_20 = "%network[:'pod_stor_20'][:interface]%"
	$iface_stor_10 = "%network[:'pod_stor_10'][:interface]%"

	$vlan_iface_one_20 = "${iface_one_20}.20"
	$vlan_iface_one_10 = "${iface_one_10}.10"
	$vlan_address_one_20 = "%network[:'pod_one_20'][:ipaddress]%/24"
	$vlan_address_one_10 = "%network[:'pod_one_10'][:ipaddress]%/24"

	$vlan_iface_ceph_20 = "${iface_ceph_20}.20"
	$vlan_iface_ceph_10 = "${iface_ceph_10}.10"
	$vlan_address_ceph_20 = "%network[:'pod_ceph_20'][:ipaddress]%/24"
	$vlan_address_ceph_10 = "%network[:'pod_ceph_10'][:ipaddress]%/24"

	$vlan_iface_stor_20 = "${iface_stor_20}.20"
	$vlan_iface_stor_10 = "${iface_stor_10}.10"
	$vlan_address_stor_20 = "%network[:'pod_stor_20'][:ipaddress]%/24"
	$vlan_address_stor_10 = "%network[:'pod_stor_10'][:ipaddress]%/24"

	#
	# network declarations
	#

	$one_db_ip = {
		'10' => {
			'0' => "192.168.10.20",
			'1' => "192.168.10.21",
			'2' => "192.168.10.22",
		},
		'20' => {
			'0' => "192.168.20.20",
			'1' => "192.168.20.21",
			'2' => "192.168.20.22",
		}
	}
	$oned_services = {
		"10" => [
		{
			"id" => 0,
			"hostname" => "oned_0_10",
			"ipaddress" => "192.168.10.1",
			"role" => 'leader'
		},
		{
			"id" => 1,
			"hostname" => "oned_1_10",
			"ipaddress" => "192.168.10.2",
			"role" => 'follower'
		},
		{
			"id" => 2,
			"hostname" => "oned_2_10",
			"ipaddress" => "192.168.10.3",
			"role" => 'follower'
		}],
		"20" => [
		{
			"id" => 0,
			"hostname" => "oned_0_20",
			"ipaddress" => "192.168.20.1",
			"role" => 'leader'
		},
		{
			"id" => 1,
			"hostname" => "oned_1_20",
			"ipaddress" => "192.168.20.2",
			"role" => 'follower'
		},
		{
			"id" => 2,
			"hostname" => "oned_2_20",
			"ipaddress" => "192.168.20.3",
			"role" => 'follower'
		}]
	}
	$one_vip = { "10" => "192.168.10.10", "20" => "192.168.20.10" }

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

	$guest_vlan_ceph_10 = net::create_vlan({
			'Ipaddress' => $vlan_address_ceph_10,
			'Vid'	    => 10,
			'Iface'     => $iface_ceph_10,
			'VlanIface' => $vlan_iface_ceph_10,
	})

	$guest_vlan_stor_20 = net::create_vlan({
			'Ipaddress' => $vlan_address_stor_20,
			'Vid'	    => 20,
			'Iface'     => $iface_stor_20,
			'VlanIface' => $vlan_iface_stor_20,
	})

	$guest_vlan_stor_10 = net::create_vlan({
			'Ipaddress' => $vlan_address_stor_10,
			'Vid'	    => 10,
			'Iface'     => $iface_stor_10,
			'VlanIface' => $vlan_iface_stor_10,
	})

	$file_templates_path = "${common::pwd()}/deploy/virt/file_templates"
	$scripts_path = "${common::pwd()}/deploy/virt/scripts"


	$raft_leader_hooks = @(END)
	RAFT_LEADER_HOOK = [
	     COMMAND = "raft/vip.sh",
	     ARGUMENTS = "leader %network[:"pod_one_<%= $id %>"][:interface]% <%= $virtual_ip %>/24"
	]

	# Executed when a server transits from leader->follower
	RAFT_FOLLOWER_HOOK = [
	    COMMAND = "raft/vip.sh",
	    ARGUMENTS = "follower %network[:"pod_one_<%= $id %>"][:interface]% <%= $virtual_ip %>/24"
	]
	| - END

}
