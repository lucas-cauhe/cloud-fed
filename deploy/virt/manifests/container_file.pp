
define virt::container_file (
	String $from = '',
	Array[String] $run = [],
	Array[String] $cmd = ['/bin/sh']
) {
	$image_path = "/tmp/Containerfile.$name"
	# ensure file with content
	file { $image_path:
		ensure => present,
		content => epp('virt/containerfile', {
			'from' => $from,
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
