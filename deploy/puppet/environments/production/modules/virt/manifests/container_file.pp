define virt::container_file (
	String $from = '',
	Array[String] $run = [],
	Array[String] $cmd = ['/bin/sh'],
	Array[String] $cp = [],
    String $file_templates_path = lookup('deployment_paths::file_templates'),
) {
	$image_path = "$file_templates_path/Containerfile.$name"
	# ensure file with content
	file { $image_path:
		ensure => present,
		content => epp('virt/containerfile', {
			'from' => $from,
			'cp' => $cp,
			'run' => $run,
			'cmd' => $cmd
		})
	}->

	# build image
	exec { "build $name container image":
		path => '/usr/bin',
		command => "podman build -f $image_path -t $name"
	}
}
