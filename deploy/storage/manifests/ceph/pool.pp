define storage::ceph::pool (
	Enum['replicated', 'erasure'] $type = 'replicated',
	Enum['on', 'off', 'warn'] $pg_autoscale = 'off',
	Optional[String] $cluster_name = undef,
	Integer $pg_num
) {

	$cluster_name_ = common::unwrap_or($cluster_name, $storage::ceph::vars::cluster_name["10"])

	notice("Defined ceph pool $name")
	#
	# Create the pool
	#
	exec { "/usr/sbin/cephadm shell -m /etc/$cluster_name_:/etc/ceph -- ceph osd pool create $name $pg_num $type --autoscale-mode=$pg_autoscale":
	}->

	#
	# Enable the pool
	#
	exec { "/usr/sbin/cephadm shell -m /etc/$cluster_name_:/etc/ceph -- ceph osd pool application enable $name rbd":
	}->

	#
	# Init the pool
	#
	exec { "/usr/sbin/cephadm shell -m /etc/$cluster_name_:/etc/ceph -- rbd pool init -p $name":
	}

}
