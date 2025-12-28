define virt::services::opennebula::datastore (
	String $one_frontend,
	Enum['ceph'] $mad,
	Enum['system', 'image'] $type,
	String $bridge_list,
	Optional[Hash] $options = undef
) {
	$ds_file = "/tmp/one-ds-$name.txt"
	if $type == 'system' {
		$type_ = 'SYSTEM_DS'
	} else {
		$type_ = 'IMAGE_DS'
	}
	#
	# Create ds file
	#
	file { $ds_file:
		ensure => 'present',
		content => epp('virt/one_ds', {
			'name' => $name,
			'mad' => $mad,
			'type' => $type_,
			'bridge_list' => $bridge_list,
			'options' => $options
		})
	}->

	#
	# Copy file to destination (podman cmd since ssh might fail)
	#
	exec { "/usr/bin/podman cp $ds_file $one_frontend:$ds_file":
	}->

	#
	# Apply ds manifest
	#
	exec { "/usr/bin/podman exec $one_frontend onedatastore create $ds_file":
	}
}
