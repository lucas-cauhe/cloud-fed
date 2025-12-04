# Author | Lucas Cauhé Viñao
# Contact | lcauhe@gmail.com
# Description | Basic interface to map to containers

# For future container types maybe allow to specify tun/tap interfaces
class net::container (
	String $net_name = 'veth0',
	Integer $vlan_id = 1,
	String $br_name = 'br0',
) {

	systemd::manage_unit { "${net_name}.network":
		
		match_entry => {
			'Name' => $net_name,
		},

		network_entry => {
			'Bridge' => $br_name,
		},

		bridge_vlan_entry => {
			'PVID' => $vlan_id,
			'EgressUntagged' => $vlan_id,
		},

	}
}
