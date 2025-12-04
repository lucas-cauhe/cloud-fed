# net/manifests/veth.pp
define net::veth (
	String	$br_src = 'br0',
	String	$br_dst = 'br1',
	String  $if_name = 'br0_br1',
	String  $rev_if_name = 'br1_br0',
	Array[Integer] $allowed_vlans = [],
) {

	systemd::manage_unit { "${if_name}.netdev":
		path => '/etc/systemd/network',
		netdev_entry => {
			'Name' => $if_name,
			'Kind' => 'veth',
		},
		peer_entry => {
			'Name' => $rev_if_name,
		}
	}

	systemd::manage_unit { "${if_name}.network":
		path => '/etc/systemd/network',
		match_entry => {
			'Name' => $if_name,
		},
		network_entry => {
			'Bridge' => $br_src,
		},
		bridge_vlan_entry => {
			'VLAN' => $allowed_vlans
		}
	}


	systemd::manage_unit { "${rev_if_name}.network":
		path => '/etc/systemd/network',
		match_entry => {
			'Name' => $rev_if_name,
		},
		network_entry => {
			'Bridge' => $br_dst,
		},
		bridge_vlan_entry => {
			'VLAN' => $allowed_vlans
		}
	}
}
