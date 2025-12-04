# Author | Lucas Cauhé Viñao
# Contact | lcauhe@gmail.com
# Description | VLAN definition 
# Docs -> https://github.com/voxpupuli/puppet-network 

define net::vlan (
	String      $id = '10',
	String      $device = 'eth0',
	Optional[String]	    $ipaddress = undef,
	Optional[String]	    $netmask = undef,
	Optional[String] $bridge = undef,
	) {

	ensure_resource('package', "vlan", { ensure => present })
	ensure_resource('file_line', "vlan module is loaded", { path => '/etc/modules', line => '8021q' })

	$vlan_name = "$device.${id}"
	$method = $ipaddress ? {
		undef => 'manual',
		default => 'static',
	}
	notice("Configuring VLAN $vlan_name using method $method") 

	network_config { $vlan_name:
		family => 'inet',
		method => $bridge ? { undef => $method, default => 'manual' },
		ensure => 'present',
		onboot => true,
		ipaddress => $bridge ? { undef => $ipaddress, default => undef },
		netmask => $bridge ? { undef => $netmask, default => undef },
		mode => "vlan",
		options => {
			'vlan-raw-device' => $device,
		}

	}

	if $bridge {
		net::bridge { $bridge:
			require => Network_config[$vlan_name],
			br_name => $bridge,
			devices => [$vlan_name],
			service_options => {
				ensure => 'present',
				onboot => true,
				method => 'static',
				ipaddress => $ipaddress,
				netmask => $netmask,
			}
		}
	}
}
