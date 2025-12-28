# Author | Lucas Cauhé Viñao
# Contact | lcauhe@gmail.com
# Description | Bridge interface definition 

define net::bridge (
	String $br_name = 'br1',
	Array[String] $devices = ['eth0'],
	Hash $service_options = {},
	) {

	ensure_resource('package', "bridge-utils", { ensure => present })

	notice("Configuring bridge $br_name on devices: $devices") 
	network_config { $br_name: 
		* => $service_options,
		options => {
			'bridge_ports' => $devices, 
		}
	}
	
}
