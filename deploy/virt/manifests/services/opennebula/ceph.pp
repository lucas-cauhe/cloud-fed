define virt::services::opennebula::ceph(
	Array[String] $frontend_nodes,
	String $fed_id
){

	#
	# Cluster setup for OpenNebula
	#
	$cluster_name = $storage::ceph::vars::cluster_name[$fed_id]

	#
	# Create `one` pool
	#
	storage::ceph::pool { "one-$fed_id":
		type => 'replicated',	
		pg_num => 128,
		pg_autoscale => 'on',
		cluster_name => $cluster_name 
	}

	#
	# Define `libvirt` ceph user
	#
	storage::ceph::user { "libvirt-$fed_id":
		type => 'client',
		cluster_name => $cluster_name,
		caps => "mon 'profile rbd' osd 'profile rbd pool=one-$fed_id'"
	}

	# One Nodes need `qemu-img` cli to work with ceph
	# (For now this is a one node deployment)
	#
	ensure_resource('package', "qemu-utils", {
		ensure => 'installed'
	})

	#
	# Place keyring and keyfile to frontend node
	#
	exec { "libvirt-key-$fed_id":
		command => "/usr/sbin/cephadm shell -m /etc/$cluster_name:/etc/ceph -- ceph auth get-key client.libvirt-$fed_id -o /etc/ceph/client.libvirt-$fed_id.key",
		require => Storage::Ceph::User["libvirt-$fed_id"]
	}
	exec { "libvirt-keyring-$fed_id":
		command => "/usr/sbin/cephadm shell -m /etc/$cluster_name:/etc/ceph -- ceph auth get client.libvirt-$fed_id -o /etc/ceph/ceph.client.libvirt-$fed_id.keyring",
		require => Storage::Ceph::User["libvirt-$fed_id"]
	}
	$frontend_nodes.each |$fnode| {
		exec { "$fnode-libvirt-key-$fed_id":
			require => Exec["libvirt-key-$fed_id"],
			command => "/usr/bin/podman cp /etc/$cluster_name/client.libvirt-$fed_id.key $fnode:/var/lib/one"
		}->
		exec { "/usr/bin/podman exec $fnode chown oneadmin:oneadmin /var/lib/one/client.libvirt-$fed_id.key":
		}
		exec { "$fnode-libvirt-keyring-$fed_id":
			require => Exec["libvirt-keyring-$fed_id"],
			command => "/usr/bin/podman cp /etc/$cluster_name/ceph.client.libvirt-$fed_id.keyring $fnode:/etc/ceph"
		}->	
		exec { "/usr/bin/podman exec $fnode chown oneadmin:oneadmin /etc/ceph/ceph.client.libvirt-$fed_id.keyring":
		}
	}

	$libvirt_secret = storage::uuid() 
	#
	# Datastores setup
	#

	#
	# System Datastore
	#
	virt::services::opennebula::datastore { "system-$fed_id":
		require => Package["qemu-utils"],
		one_frontend => $virt::containers::oned_services[$fed_id][0][hostname],
		mad => 'ceph',
		type => 'system',
		bridge_list => '10.0.13.71',
		options => {
			'pool_name' => "one-$fed_id",
			'ceph_host' => join(['"'] + $storage::ceph::vars::network[$fed_id][mon].map |$mon| { $mon[ipaddress] } + ['"'], ' '),
			'ceph_user' => "libvirt-$fed_id",
			'ceph_secret' => $libvirt_secret,
			'ceph_conf' => "/etc/$cluster_name/ceph.conf",
			'ceph_key' => "/etc/$cluster_name/client.libvirt-$fed_id.key"
		}
	}

	#
	# Image Datastore
	#
	virt::services::opennebula::datastore { "image-$fed_id":
		require => Package["qemu-utils"],
		one_frontend => $virt::containers::oned_services[$fed_id][0][hostname],
		mad => 'ceph',
		type => 'image',
		bridge_list => '10.0.13.71',
		options => {
			'pool_name' => "one-$fed_id",
			'ceph_host' => join(['"'] + $storage::ceph::vars::network[$fed_id][mon].map |$mon| { $mon[ipaddress] } + ['"'], ' '),
			'ceph_user' => "libvirt-$fed_id",
			'ceph_secret' => $libvirt_secret,
			'ceph_conf' => "/etc/$cluster_name/ceph.conf",
			'ceph_key' => "/etc/$cluster_name/client.libvirt-$fed_id.key"
		}
	}

	#
	# Hosts setup
	#

	#
	# Install ceph utils
	#
	ensure_resource('exec', "ceph-utils host install", {
		command => "/usr/sbin/cephadm install ceph-common"
	})

	#
	# Define libvirt secret in qemu 
	#
	$secret_xml = @(END)
	<secret ephemeral='no' private='no'>
		<uuid><%= $secret %></uuid>
		<usage type='ceph'>
			<name>client.libvirt-<%= $fed_id %> secret</name>
		</usage>
	</secret>
	| - END
	file { "/tmp/libvirt_secret_$fed_id.xml":
		content => inline_epp($secret_xml, {'secret' => $libvirt_secret, 'fed_id' => $fed_id}),
		ensure => 'present'
	}
	exec { "remove-secrets-$fed_id": 
		command => "/usr/bin/virsh -c qemu:///system secret-undefine --secret \"\$(/usr/bin/virsh -c qemu:///system secret-list | /usr/bin/awk '/ceph client.libvirt-$fed_id secret/ {print \$1}')\"",
		require => File["/tmp/libvirt_secret_$fed_id.xml"], 
		refreshonly => true,
		onlyif => "/usr/bin/virsh -c qemu:///system secret-list | grep \"ceph client.libvirt-10 secret\""
	}
	exec { "/usr/bin/virsh -c qemu:///system secret-define /tmp/libvirt_secret_$fed_id.xml":
		require => Exec["remove-secrets-$fed_id"],
	}->
	exec { "/usr/bin/virsh -c qemu:///system secret-set-value --secret $libvirt_secret --base64 \$(/usr/bin/cat /etc/$cluster_name/client.libvirt-$fed_id.key)":
	}
}
