# Author | Lucas Cauhé Viñao
# Contact | lcauhe@gmail.com
# Description | Host interfaces definition
# Path | net/manifests/ifaces.pp
class net::ifaces (
    String $frontend_address,
    String $frontend_gateway,
	) {


	# Install debian routes provider
	# Docs -> https://github.com/voxpupuli/puppet-network/tree/14d7f2f7d225ef93b0bf5be39b34506066132245?tab=readme-ov-file#dependencies
    include 'network'

	#network_config { 'lo':
	#	ensure => 'present',
	#	onboot => 'true',
	#	family => 'inet',
	#	method => 'loopback',
	#	ipaddress => '127.0.0.1',
	#	netmask => '255.0.0.0',
	#}
	#network_config { 'eth1':
	#	ensure => 'present',
	#	onboot => 'true',
	#	method => 'manual',
	#	options => {
	#		'bridge_ports' => ['frontend']
	#	}
	#}

    systemd::manage_unit { "br_stor.netdev":
        path => '/etc/systemd/network',
        netdev_entry => {
            'Name' => "br_stor",
            'Kind' => 'bridge',
        },

        bridge_entry => {
            'STP' => 'yes',
            #'VLANFiltering' => 'yes',
        },
        service_restart => true
    }

    systemd::manage_unit { "br_stor.network":
        path => '/etc/systemd/network',
        match_entry => {
            'Name' => 'br_stor',
        },
        #bridge_vlan_entry => {
        #	'VLAN' => [10, 20],
        #}
    }

	#systemd::manage_unit { "frontend.netdev":
	#	path => '/etc/systemd/network',
	#	netdev_entry => {
	#		'Name' => "frontend",
	#		'Kind' => 'bridge',
	#	},
	#	#bridge_entry => {
	#	#	'VLANFiltering' => 'yes',
	#	#},
	#	service_restart => true
	#} ->
	#systemd::manage_unit { "frontend.network":
	#	path => '/etc/systemd/network',
	#	match_entry => {
	#		'Name' => 'frontend',
	#	},
	#	network_entry => {
	#		'Address' => $frontend_address,
	#		'Gateway' => $frontend_gateway
	#	},
	#} ->
	#systemd::manage_unit { "eth1.network":
	#	path => '/etc/systemd/network',
	#	match_entry => {
	#		'Name' => 'eth1',
	#	},
	#	network_entry => {
	#		'Bridge' => 'frontend'
	#	}
	#} ->

	exec { "systemctl daemon-reload && systemctl restart systemd-networkd ":
		path => '/usr/bin'
	}
}
