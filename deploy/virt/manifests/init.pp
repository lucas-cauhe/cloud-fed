class virt {
	include virt::containers
	file { "/etc/containers/systemd":
		ensure => 'directory',
	}
	$virt::containers::deployment_units.each |$id| {
		virt::podman_network { "network-$id":
			require => File["/etc/containers/systemd"],
			id => $id
		}
	}
	class {'virt::services::gateway':
		require => $virt::containers::deployment_units.map |$du| { Virt::Podman_network["network-$du"] },
	}
    #
    # Deploy ceph clusters
    #
	$virt::containers::deployment_units.each |$id| {
		storage::ceph {"ceph-$id":
			require => Class["virt::services::gateway"],
			id => $id
		}
	}

    #
    # Deploy master zone in HA
    #
    virt::services::opennebula { "master-zone":
        require => Storage::Ceph["ceph-10"],
        id => '10',
        mode => 'ha',
        zone_id => '0'
    }

    #
    # Deploy slave leader node
    #
    virt::services::opennebula { "slave-leader":
        require => Storage::Ceph["ceph-20"],
        id => '20',
        mode => 'slave_leader',
        zone_id => '0'
    }

    #
    # Deploy federation
    #
	virt::services::opennebula::federation { "nebula-federation":
		require => Virt::Services::Opennebula["slave-leader"],
		master => '10',
		slaves => ['20']
	}

    #
    # Start HA cluster in slave zone
    #
    virt::services::opennebula::ha { "slave-zone-ha":
        require => Virt::Services::Opennebula::Federation["nebula-federation"],
        oned => $virt::containers::oned_services['20'][0],
        zone => '100',
        vip => $virt::containers::one_vip['20']
    }

    #
    # Attach slave follower nodes to HA cluster
    #
    virt::services::opennebula { "slave-followers":
        require => Virt::Services::Opennebula::Ha["slave-zone-ha"],
        id => '20',
        mode => 'slave_followers',
        leader => $virt::containers::oned_services['20'][0],
        zone_id => '100',
        master => '10'
    }

    #
    # Deploy Backup services
    #
	$virt::containers::deployment_units.each |$id| {
        virt::services::opennebula::backup { "backup-$id":
            require => Virt::Services::Opennebula["slave-followers"],
            cluster_name => "ceph-$id",
            user_name    => "backup"
        }
    }
}
