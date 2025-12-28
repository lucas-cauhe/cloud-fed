define storage::ceph (
	String $id
) {
	#
	# Inlcude ceph vars
	#
	include storage::ceph::vars
	$cluster_name = $storage::ceph::vars::cluster_name
	$fsid = $storage::ceph::vars::fsid
	$network = $storage::ceph::vars::network
	$ceph_release = $storage::ceph::vars::ceph_release

	#
	# Install & Configure cephadm
	#
	storage::ceph::cephadm { "cephadm-$id":
		config_path => "/etc/${cluster_name[$id]}",
		fsid => $fsid[$id],
		monitors => $network[$id][mon]
	}

	#
	# Connect cephadm to podman network
	# (the gateway container is provided with an iptables entry that allows traffic into the tagged
	# network that is useful now)
	#
	#exec { "/usr/bin/ip route replace 192.168.$id.0/24 via ${network[$id][network_gateway]}":
	#	require => Storage::Ceph::Cephadm["cephadm-$id"]
	#}

	$hostnames = $network[$id][mon].map |$m| { $m[hostname] }
	$batch_hostnames = $hostnames[1,-1]

	#
	# Bootstrap monitor
	#
	storage::ceph::monitor { "${hostnames[0]}":
		require => Storage::Ceph::Cephadm["cephadm-$id"],
		bootstrap => true,
		fsid => $fsid[$id],
		monitors => $network[$id][mon],
		pub_net => $network[$id][ceph_public_net],
		cluster_net => $network[$id][ceph_cluster_net],
		cluster_name => $cluster_name[$id],
		id => $id
	} ->


	#
	# Add 2 monitors to cluster
	#
	storage::ceph::monitor { $batch_hostnames:
		fsid => $fsid[$id],
		monitors => $network[$id][mon],
		pub_net => $network[$id][ceph_public_net],
		cluster_net => $network[$id][ceph_cluster_net],
		cluster_name => $cluster_name[$id],
		id => $id
	}->

	#
	# Enable the msgr2 version protocol
	#
	exec { "/usr/sbin/cephadm shell -m /etc/${cluster_name[$id]}:/etc/ceph -- ceph mon enable-msgr2":
	}

	#
	# Add managers to cluster
	#
	$network[$id][mgr].each |$mgr| {
		storage::ceph::manager { $mgr[hostname]:
			require => $network[$id][mon].map |$mon| { Storage::Ceph::Monitor["${mon[hostname]}"] },
			ipaddress => $mgr[ipaddress],
			mon => $network[$id][mon][0],
			cluster_name => $cluster_name[$id],
			id => $id
		}
	}

	#
	# Add osds
	#
	$network[$id][osds].each |$osd| {
		storage::ceph::osd { $osd[hostname]:
			require => Storage::Ceph::Manager["${network[$id][mgr][0][hostname]}"],
			mon => $network[$id][mon][0],
			ipaddress => $osd[ipaddress],
			cluster_ipaddress => $osd[cluster_ipaddress],
			cluster_name => $cluster_name[$id],
			id => $id
		}
	}

	#
	# Add CephFS
	#
	storage::ceph::cephfs { "myfs-$id":
		require => Storage::Ceph::Osd["${network[$id][osds][0][hostname]}"],
		cluster_name => $cluster_name[$id],
		id => $id
	}

    #
    # Add RGW
    #
    storage::ceph::rgw { "rgw-$id":
        require => Storage::Ceph::Cephfs["myfs-$id"],
        cluster_name => $cluster_name[$id],
        fsid => $fsid[$id],
        id => $id,
        mon => $network[$id][mon][0],
        ipaddress => $network[$id][rgw][0][ipaddress],
        role => $id ? {
            '10' => 'master',
            default => 'slave'
        },
        rgw_options => {
            'realm_name' => 'opennebula',
            'zonegroup_name' => 'marketplace',
            'zonegroup_address' => '192.168.10.95:7480',
            'zone_name' => "one-$id",
        }
    }


}
