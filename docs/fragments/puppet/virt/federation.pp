define virt::services::opennebula::federation (
	String $master,
	Array[String] $slaves
) {
	#
	# Master should already be configured
	#
	$master_container = $virt::containers::oned_services[$master][0][hostname]
	$env = $facts['env_vars']
	$db_passwd = $env['MARIADB_ONE_PASSWD']

	#
	# Configure master
	#
    virt::services::opennebula::fed_masters_setup { "fed_masters_setup":
        master_container => $master_container,
        masters_vip => $virt::containers::one_vip[$master],
        masters_id => '10'
    }

    #
    # Stop slave zones
    #
    virt::services::opennebula::stop_slaves { "stop-one-slaves":
        require => Virt::Services::Opennebula::Fed_masters_setup["fed_masters_setup"],
        slaves => $slaves
    }

	#
	# Create zones from master
	#
	$slaves.each |$slave| {
        virt::services::opennebula::zone { "zone-$slave":
			require => Virt::Services::Opennebula::Stop_slaves["stop-one-slaves"],
            slave_id => $slave,
            slave_endpoint => $virt::containers::oned_services[$slave][0][ipaddress],
            master => $master_container
        }
	}

	#
	# Make master db snapshot
	#
	exec { "federated-snap":
		require => Virt::Services::Opennebula::Zone["zone-20"],
        refreshonly => true,
		command => "/usr/bin/podman exec $master_container onedb backup --federated -S ${virt::containers::one_db_ip[$master]['0']} -t mysql -u oneadmin -p $db_passwd -d opennebula -f /var/lib/one/one.db"
	}

	#
	# Adding slaves
	#


	#
	# Copy db & auth files
	#
	$slaves.each |$slave| {
        $slave_service = $virt::containers::oned_services[$slave][0]
		exec { "/usr/bin/podman cp $master_container:/var/lib/one/one.db ${slave_service[hostname]}:/tmp/one.db":
            require => Exec["federated-snap"],
            refreshonly => true
		}->
		exec { "$slave-db-restore":
			command => "/usr/bin/podman exec ${slave_service[hostname]} onedb restore --federated -S ${virt::containers::one_db_ip[$slave]['0']} -t mysql -u oneadmin -p $db_passwd -d opennebula /tmp/one.db"
		}->
        exec { "/usr/bin/podman cp $master_container:/var/lib/one/.one ${slave_service[hostname]}:/tmp/one_auths":
        }->
        exec { "/usr/bin/podman exec ${slave_service[hostname]} mv -f /tmp/one_auths/one_auth /var/lib/one/.one":
            refreshonly => true
        }->
        exec { "/usr/bin/podman exec ${slave_service[hostname]} mv -f /tmp/one_auths/oneflow_auth /var/lib/one/.one":
            refreshonly => true
        }->
        exec { "/usr/bin/podman exec ${slave_service[hostname]} mv -f /tmp/one_auths/onegate_auth /var/lib/one/.one":
            refreshonly => true
        }->
        exec { "/usr/bin/podman exec ${slave_service[hostname]} mv -f /tmp/one_auths/sunstone_auth /var/lib/one/.one":
            refreshonly => true
        }->
        virt::container_provision { "${slave_service[hostname]}_fed_provision":
            require => Exec["$slave-db-restore"],
            container_name => $slave_service[hostname],
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
                                'dest' => "MASTER_ONED   = \"http://${virt::containers::one_vip[$master]}:2633/RPC2\""
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
                        ["%expect[0.0.0.0:2633]% podman exec ${slave_service[hostname]} ss -tulpn"]
                }
            ]
        }
	}
}
