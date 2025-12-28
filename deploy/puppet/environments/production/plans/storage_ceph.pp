plan cloud_fed::storage_ceph(TargetSpec $targets) {
   $result = apply($targets, _run_as => 'root') {

        #
        # Deploy ceph clusters
        #
        storage::ceph {lookup('ceph', Hash, 'deep')[cluster_name]:
            id => lookup('id')
        }

        #
        # Deploy backup cephfs
        #
        storage::ceph::newfs { "backup-${lookup('id')}":
            require => Storage::Ceph[
                lookup('ceph', Hash, 'deep')[cluster_name]
            ],
            cluster_name => lookup('ceph', Hash, 'deep')[cluster_name],
            user_name    => lookup('ceph', Hash, 'deep')[backup][username]
        }

        #
        # Deploy policies cephfs
        #
        storage::ceph::newfs { "policies-${lookup('id')}":
            require => Storage::Ceph[
                lookup('ceph', Hash, 'deep')[cluster_name]
            ],
            cluster_name => lookup('ceph', Hash, 'deep')[cluster_name],
            user_name    => lookup('ceph', Hash, 'deep')[policies][username]
        }
    }
    if $result.ok() {
        out::message("Ceph storage cluster deployed successfully")
    } else {
        fail_plan(
            'Ceph storage cluster deployment was unsuccessful',
            'storage_ceph error',
            {'result' => $result.error()}
        )
    }

    return $result
}
