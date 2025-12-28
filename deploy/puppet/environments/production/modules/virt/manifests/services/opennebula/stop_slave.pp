define virt::services::opennebula::stop_slave (
    String $slave
) {
	#
	# Stop slave One in HA
	#
    exec { "/usr/bin/podman exec ${lookup('opennebula')[services][0][hostname]} one stop":
    }
}
