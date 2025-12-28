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
    # Create s3 user
    #
    storage::ceph::s3_user { "nebula":
        require => [Storage::Ceph["ceph-10"],Storage::Ceph["ceph-20"]],
        display_name => "Nebula S3"
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
    # Deploy Cephfs for backup and OPA
    #
	$virt::containers::deployment_units.each |$id| {
        storage::ceph::newfs { "backup-$id":
            require => Virt::Services::Opennebula["slave-followers"],
            cluster_name => "ceph-$id",
            user_name    => "backup"
        }
        storage::ceph::newfs { "policies-$id":
            require => Virt::Services::Opennebula["slave-followers"],
            cluster_name => "ceph-$id",
            user_name    => "policies"
        }
    }

    #
    # Increase last_oid column to prevent libvirt ids collisions
    #
    exec { "/usr/bin/podman exec one-db-0-20 mariadb -u root -proot -D opennebula -e \"UPDATE pool_control SET last_oid=100 WHERE tablename='vm_pool';\"":
        require => Virt::Services::Opennebula["slave-followers"],
        refreshonly => true
    }

    #
    # Start monitoring service
    #
    $virt::containers::deployment_units.each |$id| {
        virt::services::opennebula::monitoring { "monitoring-$id":
            require => Virt::Services::Opennebula["slave-followers"],
            zone_id => $id
        }
    }
}
