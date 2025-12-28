define virt::services (
	String $id
) {
	virt::services::opennebula { "nebula-$id":
		require => Class['virt::services::gateway'],
		id => $id
	}
}
