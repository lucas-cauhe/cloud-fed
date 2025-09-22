define virt::services::opennebula::stop_slaves (
    Array[String] $slaves
) {
	#
	# Stop slaves One in HA
	#
	$slaves.each |$slave| {
        exec { "/usr/bin/podman exec ${virt::containers::oned_services[$slave][0][hostname]} one stop":
            refreshonly => true
        }
	}
}
