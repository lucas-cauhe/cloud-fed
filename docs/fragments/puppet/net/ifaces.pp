# Author | Lucas Cauhé Viñao
# Contact | lcauhe@gmail.com
# Description | Host interfaces definition
# Path | net/manifests/ifaces.pp
class net::ifaces (
	) {


	# Install debian routes provider
	# Docs -> https://github.com/voxpupuli/puppet-network/tree/14d7f2f7d225ef93b0bf5be39b34506066132245?tab=readme-ov-file#dependencies
	if $facts['os']['name'] == 'Debian' {
		include 'network'
	}

	network_config { 'lo':
		ensure => 'present',
		onboot => 'true',
		family => 'inet',
		method => 'loopback',
		ipaddress => '127.0.0.1',
		netmask => '255.0.0.0',
	}
	network_config { 'eno3':
		ensure => 'present',
		onboot => 'true',
		method => 'manual',
		options => {
			'bridge_ports' => ['frontend']
		}
	}

	$bridge_ifaces = ['br_one', 'br_ceph', 'br_kvm', 'br_stor']

	$bridge_ifaces.each |$iface| {
		systemd::manage_unit { "${iface}.netdev":
			path => '/etc/systemd/network',
			netdev_entry => {
				'Name' => "${iface}",
				'Kind' => 'bridge',
			},

			bridge_entry => {
				'STP' => 'yes',
				'VLANFiltering' => 'yes',
			},
			service_restart => true
		}

		systemd::manage_unit { "${iface}.network":
			path => '/etc/systemd/network',
			match_entry => {
				'Name' => $iface,
			},
			bridge_vlan_entry => {
				'VLAN' => [10, 20],
			}
		}
	}

	systemd::manage_unit { "frontend.netdev":
		path => '/etc/systemd/network',
		netdev_entry => {
			'Name' => "frontend",
			'Kind' => 'bridge',
		},

		bridge_entry => {
			'VLANFiltering' => 'yes',
		},
		service_restart => true
	} ->
	systemd::manage_unit { "frontend.network":
		path => '/etc/systemd/network',
		match_entry => {
			'Name' => 'frontend',
		},
		network_entry => {
			'Address' => "10.0.13.71/24",
			'Gateway' => "10.0.13.254"
		},
	} ->
	systemd::manage_unit { "eno3.network":
		path => '/etc/systemd/network',
		match_entry => {
			'Name' => 'eno3',
		},
		network_entry => {
			'Bridge' => 'frontend'
		}
	} ->
	network_route { 'default':
		ensure => 'present',
		network => 'default',
		gateway => '10.0.13.254',
		interface => 'frontend',
		netmask => '0.0.0.0',
	} ->
	# VETH interfaces for interconnecting bridges as required
	net::veth { "veth_one_ceph":
		br_src => 'br_one',
		br_dst => 'br_ceph',
		if_name => 'one_ceph',
		rev_if_name => 'ceph_one',
		allowed_vlans => [10, 20],
	} ->
	net::veth { "veth_one_kvm":
		br_src => 'br_one',
		br_dst => 'br_kvm',
		if_name => 'one_kvm',
		rev_if_name => 'kvm_one',
		allowed_vlans => [10, 20],
	} ->
	exec { "systemctl daemon-reload && systemctl restart systemd-networkd ":
		path => '/usr/bin'
	}

}
