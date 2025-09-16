define storage::ceph::rbd (
	String $conf = '/etc/ceph',
	String $pool,
	String $image,
	String $size,
	String $mountpoint,
) {
	#
	# Define pool & image
	#
	storage::ceph::pool { $pool:
		pg_autoscale => 'on',
		pg_num => 128
	}->
	exec { "create-rbd-image-$image":
		refreshonly => true,
		command => "/usr/sbin/cephadm shell -m $conf:/etc/ceph -- rbd create --size $size --pool $pool $image"
	}

	#
	# Add cephx authz
	#
	exec { "/usr/sbin/cephadm shell -m $conf:/etc/ceph -- ceph auth get-or-create client.$name mon 'allow r' osd 'allow rwx pool=$pool' > $conf/ceph.client.$name.keyring":
	}

	#
	# Map rbd device on the host
	#
	exec { "/usr/sbin/modprobe rbd":
	}->
	exec { "/usr/sbin/cephadm shell -m $conf:/etc/ceph -- rbd -n client.$name -c /etc/ceph/ceph.conf -k /etc/ceph/ceph.client.$name.keyring --id $name map --pool $pool $image":
		require => Exec["create-rbd-image-$image"],
		refreshonly => true
	} ->
	exec { "/usr/sbin/mkfs.xfs /dev/rbd2":
		refreshonly => true
	}->
	exec { "/usr/bin/mount /dev/rbd2 $mountpoint":
		refreshonly => true
	}


}
