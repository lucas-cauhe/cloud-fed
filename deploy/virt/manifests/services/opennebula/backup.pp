define virt::services::opennebula::backup (
    String $cluster_name = 'ceph',
    String $user_name = 'backup'
) {

    #
    # Create EC 3-1 profile Ceph pool
    #
    storage::ceph::pool { "backup_data-$cluster_name":
        type => 'erasure',
        cluster_name => $cluster_name,
        pg_autoscale => 'on',
        rbd => false,
        ecpool_opts => {
            'k' => 3,
            'm' => 1
        }
    }

    storage::ceph::pool { "backup_meta-$cluster_name":
        type => 'replicated',
        cluster_name => $cluster_name,
        pg_autoscale => 'on',
        rbd => false,
    }

    #
    # Define crush rule for the least occupied HDD drives to form the EC pool
    #

    #
    # Define a CephFS over the EC pool
    #
    exec { "/usr/sbin/cephadm shell -m /etc/$cluster_name:/etc/ceph -- ceph osd pool set backup_data-$cluster_name allow_ec_overwrites true":
        require => [Storage::Ceph::Pool["backup_meta-$cluster_name"],Storage::Ceph::Pool["backup_data-$cluster_name"]],
        refreshonly => true
    }->
    exec { "/usr/sbin/cephadm shell -m /etc/$cluster_name:/etc/ceph -- ceph fs new backup backup_meta-$cluster_name backup_data-$cluster_name --force":
        refreshonly => true
    }->

    #
    # Create user for pool
    #
    exec { "/usr/sbin/cephadm shell -m /etc/$cluster_name:/etc/ceph -- ceph fs authorize backup client.$user_name / rw > /etc/$cluster_name/ceph.client.$user_name.keyring":
        refreshonly => true
    }


}
