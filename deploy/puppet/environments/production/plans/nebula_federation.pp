plan cloud_fed::nebula_federation(
    String $master,
    Array[String] $slaves
){
    $master_target = get_target('master')
    $slaves_targets = get_targets('slaves')
    $slave_host = get_target('vm1-cert')

    $master_fed_result = apply($master_target, _run_as => 'root') {
        $master_container = lookup('opennebula')[services][0][hostname]

        #
        # Configure master
        #
        virt::services::opennebula::fed_masters_setup { "fed_masters_setup":
            master_container => $master_container,
            masters_vip => lookup('opennebula')[vip],
            masters_id => lookup('id')
        }

        #
        # Create zones from master
        #
        $slaves.each |$slave| {
            virt::services::opennebula::zone { "zone-$slave":
                require => Virt::Services::Opennebula::Fed_masters_setup["fed_masters_setup"],
                slave_id => $slave,
                slave_endpoint => lookup('opennebula', Hash, 'deep')[slave_endpoints][$slave],
                master => $master_container
            }
        }

        #
        # Make master db snapshot
        #
        exec { "federated-snap":
            require => Virt::Services::Opennebula::Zone["zone-20"],
            command => "/usr/bin/podman exec $master_container onedb backup --federated -S ${lookup('opennebula')[db]['0']} -t mysql -u oneadmin -p ${lookup('opennebula', Hash, 'deep')[db_config][one_passwd]} -d opennebula -f /var/lib/one/one.db"
        }


        #
        # Copy files from master to slaves
        #
        $slaves.each |$slave| {
            exec { "/usr/bin/podman cp $master_container:/var/lib/one/one.db /tmp/one.db":
                require => Exec["federated-snap"],
            }->
            exec { "/usr/bin/podman cp $master_container:/var/lib/one/.one /tmp/one_auths":
                require => Exec["federated-snap"],
            }->
            exec { "/usr/bin/scp -o 'StrictHostKeyChecking=no' -i /home/vagrant/.ssh/id_ecdsa -r /tmp/one_auths vagrant@${slave_host.uri()}:/tmp":
            }->
            exec { "/usr/bin/scp -o 'StrictHostKeyChecking=no' -i /home/vagrant/.ssh/id_ecdsa /tmp/one.db vagrant@${slave_host.uri()}:/tmp":
            }
        }
    }

    $slave_fed_result = apply($slaves_targets, _run_as => 'root') {
        #
        # Stop slave zones
        #
        virt::services::opennebula::stop_slave { "stop-one-slaves":
            slave => lookup('id')
        }->
        exec { "/usr/bin/podman cp /tmp/one.db ${lookup('opennebula')[services][0][hostname]}:/tmp/one.db":
        } ->
        exec { "slave-${lookup('id')}-db-restore":
            command => "/usr/bin/podman exec ${lookup('opennebula')[services][0][hostname]} onedb restore --federated -S ${lookup('opennebula')[db]['0']} -t mysql -u oneadmin -p ${lookup('opennebula', Hash, 'deep')[db_config][one_passwd]} -d opennebula /tmp/one.db"
        }->
        exec { "/usr/bin/podman cp /tmp/one_auths ${lookup('opennebula')[services][0][hostname]}:/tmp/one_auths":
        }->
        exec { "/usr/bin/podman exec ${lookup('opennebula')[services][0][hostname]} mv -f /tmp/one_auths/one_auth /var/lib/one/.one":
        }->
        exec { "/usr/bin/podman exec ${lookup('opennebula')[services][0][hostname]} mv -f /tmp/one_auths/oneflow_auth /var/lib/one/.one":
        }->
        exec { "/usr/bin/podman exec ${lookup('opennebula')[services][0][hostname]} mv -f /tmp/one_auths/onegate_auth /var/lib/one/.one":
        }->
        exec { "/usr/bin/podman exec ${lookup('opennebula')[services][0][hostname]} mv -f /tmp/one_auths/sunstone_auth /var/lib/one/.one":
        }->
        virt::container_provision { "${lookup('opennebula')[services][0][hostname]}_fed_provision":
            require => Exec["slave-${lookup('id')}-db-restore"],
            container_name => lookup('opennebula')[services][0][hostname],
            plan => [
                {
                    "type" => "guest_file",
                    "actions" => [
                        {
                            'path' => '/etc/one/oned.conf',
                            'replace' => {
                                'src' => "ZONE_ID       = 0",
                                'dest' => "ZONE_ID       = 100"
                            }
                        },
                        {
                            'path' => '/etc/one/oned.conf',
                            'replace' => {
                                'src' => "MASTER_ONED   = \"\"",
                                'dest' => "MASTER_ONED   = \"http://${lookup('opennebula')[master_vip]}:2633/RPC2\""
                            }
                        },
                        {
                            'path' => '/etc/one/oned.conf',
                            'replace' => {
                                'src' => "\"STANDALONE\"",
                                'dest' => "\"SLAVE\""
                            }
                        },

                    ]
                },
                {
                    "type" => "guest",
                    "actions" => [
                        "chown -R oneadmin:oneadmin /var/lib/one/.one",
                        "su oneadmin - -c \"one start\""
                    ]
                },
                {
                    "type" => "container",
                    "actions" =>
                        ["%expect[0.0.0.0:2633]% podman exec ${lookup('opennebula')[services][0][hostname]} ss -tulpn"]
                }
            ]
        }

    }

    return {
        master => $master_fed_result,
        slaves => $slave_fed_result,
    }

}
