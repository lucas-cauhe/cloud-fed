define storage::ceph::rbd (
	String $cluster_name = 'ceph',
	String $pool,
	String $image,
	String $size,
	String $mountpoint,
) {
	$pwd = common::pwd()
	$scripts_path = "$pwd/deploy/storage/scripts"

	#
	# Define pool & image
	#
	ensure_resource('storage::ceph::pool', $pool, {
		pg_autoscale => 'on',
		pg_num => "128",
		cluster_name => $cluster_name
	})
	exec { "create-rbd-image-$cluster_name-$image":
		require => Storage::Ceph::Pool[$pool],
		refreshonly => true,
		command => "/usr/sbin/cephadm shell -m /etc/$cluster_name:/etc/ceph -- rbd create --size $size --pool $pool $image"
	}

	#
	# Add cephx authz
	#
	exec { "/usr/sbin/cephadm shell -m /etc/$cluster_name:/etc/ceph -- ceph auth get-or-create client.$name mon 'allow r' osd 'allow rwx pool=$pool' > /etc/$cluster_name/ceph.client.$name.keyring":
	}

	#
	# Map rbd device on the host
	#
	exec { "/usr/bin/ruby $scripts_path/rbdmap.rb $cluster_name $name $pool $image $mountpoint":
		require => Exec["create-rbd-image-$cluster_name-$image"]
	}


}
