
define virt::podman_unit (
	Hash $args,
){
    #
    # Variables locales
    #
	notice("Defining podman unit $name")
	$unit_name = "puppet-podman-$name"
	$mid = regsubst($unit_name, /\.container/, '', 'G')
	$quadlet_name = regsubst($mid, /\./, '-', 'G')

    #
    # Creación de fichero unit
    #
	systemd::manage_unit { $unit_name:
		path => '/etc/containers/systemd',
		* => $args,
	} ->
    #
    # Transforma systemd unit contenedor a systemd nativo
    #
	exec { "generate quadlet $unit_name":
		command => 'podman-system-generator /etc/systemd/system',
		path => '/usr/lib/systemd/system-generators',
	} ->

    #
    # Incorporar unidad al estado de la máquina
    #
	exec { "systemctl daemon-reload && systemctl start $quadlet_name":
		path => '/usr/bin',
	}

}
