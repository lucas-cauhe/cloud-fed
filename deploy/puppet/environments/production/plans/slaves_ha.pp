plan cloud_fed::slaves_ha(TargetSpec $targets) {
        $ha_deploy = apply($targets, _run_as => 'root') {
            #
            # Start HA cluster in slave zone
            #
            virt::services::opennebula::ha { "slave-zone-ha":
                oned => lookup('opennebula')[services][0],
                zone => lookup('opennebula')[zone_id],
                vip => lookup('opennebula')[vip]
            }

            #
            # Attach slave follower nodes to HA cluster
            #
            virt::services::opennebula { "slave-followers":
                require => Virt::Services::Opennebula::Ha["slave-zone-ha"],
                id => lookup('id'),
                mode => lookup('opennebula')[ha_mode][1],
                leader => lookup('opennebula')[services][0],
                zone_id => lookup('opennebula')[zone_id],
                master => lookup('opennebula')[master_id]
            }
        }

        if $ha_deploy.ok() {
            out::message("Slave HA zone deployment was successful")
        } else {
            fail_plan(
                'Slave HA zone deployment was unsuccessful',
                'slaves_ha error',
                {'result' => $ha_deploy.error()}
            )
        }
        return $ha_deploy
}
