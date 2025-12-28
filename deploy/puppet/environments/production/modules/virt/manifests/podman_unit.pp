
define virt::podman_unit (
	Hash $args,	
){
	notice("Defining podman unit $name")
	$unit_name = "puppet-podman-$name"
	$mid = regsubst($unit_name, /\.container/, '', 'G') 
	$quadlet_name = regsubst($mid, /\./, '-', 'G') 
	systemd::manage_unit { $unit_name:
		path => '/etc/containers/systemd',
		* => $args,
	} -> 
	exec { "generate quadlet $unit_name": 
		command => 'podman-system-generator /etc/systemd/system',
		path => '/usr/lib/systemd/system-generators',
	} ->
	exec { "systemctl daemon-reload && systemctl start $quadlet_name":
		path => '/usr/bin',
	}
	
}
