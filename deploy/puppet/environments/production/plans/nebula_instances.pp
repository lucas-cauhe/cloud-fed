plan cloud_fed::nebula_instances() {
        $master_deploy = apply('vm0-cert', _run_as => 'root') {
            #
            # Create s3 user
            #
            storage::ceph::s3_user { "nebula":
                display_name => "Nebula S3",
                cluster_name => "ceph-${lookup('id')}"
            }

            #
            # Deploy master zone in HA
            #
            virt::services::opennebula { "master-zone":
                id => lookup('id'),
                mode => lookup('opennebula', Hash, 'deep')[ha_mode],
                zone_id => lookup('opennebula', Hash, 'deep')[zone_id]
            }
        }

        if $master_deploy.ok() {
            out::message("Master zone deployed successfully")
        } else {
            fail_plan(
                'Master zone deployment was unsuccessful',
                'nebula_instances error',
                {'result' => $master_deploy.error()}
            )
        }

        $slave_deploy = apply('vm1-cert', _run_as => 'root') {
            virt::services::opennebula { "slave-leader":
                id => lookup('id'),
                mode => lookup('opennebula', Hash, 'deep')[ha_mode][0],
                zone_id => lookup('opennebula', Hash, 'deep')[master_zone_id]
            }
        }

        if $slave_deploy.ok() {
            out::message("Slave zone deploy successfully")
        } else {
            fail_plan(
                'Slave zone deployment was unsuccessful',
                'nebula_instances error',
                {'result' => $slave_deploy.error()}
            )
        }
        return {
            master_zone => $master_deploy,
            slave_zone => $slave_deploy,
        }
}
