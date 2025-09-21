define virt::services::opennebula::federation (
	String $master,
	Array[String] $slaves
) {
	#
	# Master should already be configured
	#
	$master_container = $virt::containers::oned_services[$master][0][hostname]
	$env = $facts['env_vars']
	$db_passwd = $env['MARIADB_ONE_10_PASSWD']

	#
	# Configure master
	#
	$virt::containers::oned_services[$master].each |$master_node| {
		virt::container_provision { "${master_node[hostname]}_second_provision":
			container_name => $master_node[hostname],
			plan => [
				{
					"type" => "guest_file",
					"actions" => [
						{
							'path' => '/etc/one/oned.conf',
							'replace' => {
								'src' => "\"STANDALONE\"",
								'dest' => "\"MASTER\""
							}
						}
					]
				},
				{
					"type" => "guest",
					"actions" => ["su oneadmin - -c \"one restart\""]
				}
			]
		}
	}
	virt::container_provision {"fed_master_provision":
		container_name => $master_container,
		plan => [
			# wait for server to become leader
			{
				"type" => "container",
				"actions" =>
					[
					"%expect[<STATE>3</STATE>]% podman exec $master_container onezone show -x 0",

					]
			},
			{
				"type" => "guest_file",
				"actions" => [
					{
						'path' => '/tmp/update_zone.one',
						'content' => "ENDPOINT=\"http://${virt::containers::one_vip[$master]}:2633/RPC2\""
					}
				]
			},
			{
				"type" => "guest",
				"actions" => ["onezone update 0 /tmp/update_zone.one", "su oneadmin - -c \"one restart\""]
			},
            {
				"type" => "container",
				"actions" =>
					[
					"%expect[0.0.0.0:2633]% podman exec $master_container ss -tulpn",
					"%expect[<STATE>3</STATE>]% podman exec $master_container onezone show -x 0"
					]
			}
		]}

	#
	# Adding slaves
	#

	#
	# Stop slaves One in HA
	#
	$slaves.each |$slave| {
		$virt::containers::oned_services[$slave].each |$slave_service| {
			exec { "fed-stop-slave-${slave_service[hostname]}":
                command => "/usr/bin/podman exec ${slave_service[hostname]} one stop",
                require => Virt::Container_provision["fed_master_provision"],
                refreshonly => true
			}
		}
	}

	#
	# Make master db snapshot
	#
	exec { "federated-snap":
		require => Virt::Container_provision["fed_master_provision"],
        refreshonly => true,
		command => "/usr/bin/podman exec $master_container onedb backup --federated -S ${virt::containers::one_db_ip[$master]['0']} -t mysql -u oneadmin_10 -p $db_passwd -d opennebula_10 -f /var/lib/one/one.db"
	}

	#
	# Create zones from master
	#
	$slaves.each |$slave| {
		file { "/tmp/$slave-zone.tmpl":
			ensure => 'present',
			content => "NAME = zone-$slave
			ENDPOINT = http://${virt::containers::one_vip[$slave]}:2633/RPC2"
		}->
		exec {"/usr/bin/podman cp /tmp/$slave-zone.tmpl $master_container:/tmp/$slave-zone.tmpl":
            refreshonly => true
		}->
		exec { "/usr/bin/podman exec $master_container onezone create /tmp/$slave-zone.tmpl > /tmp/$slave-zone-id":
			require => Exec["federated-snap"],
            refreshonly => true
		}
	}

	#
	# Copy db & auth files
	#
	$slaves.each |$slave| {
		$slave_db_passwd_var = "MARIADB_ONE_${slave}_PASSWD"
		$slave_db_passwd = $env[$slave_db_passwd_var]
		exec { "/usr/bin/podman cp $master_container:/var/lib/one/one.db ${virt::containers::oned_services[$slave][0][hostname]}:/tmp/one.db":
            require => [Exec["federated-snap"], Exec["fed-stop-slave-${virt::containers::oned_services[$slave][0][hostname]}"]],
            refreshonly => true
		}->
		exec { "$slave-db-restore":
			command => "/usr/bin/podman exec ${virt::containers::oned_services[$slave][0][hostname]} onedb restore --federated -S ${virt::containers::one_db_ip[$slave]['0']} -t mysql -u oneadmin_$slave -p $slave_db_passwd -d opennebula_$slave /tmp/one.db"
		}
		$virt::containers::oned_services[$slave].each |$slave_service| {
			exec { "/usr/bin/podman cp $master_container:/var/lib/one/.one/one_auth ${slave_service[hostname]}:/var/lib/one/.one/one_auth":
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

						]
					},
					{
						"type" => "guest",
						"actions" => [
							"chown -R oneadmin:oneadmin /var/lib/one/.one",
							"su oneadmin - -c \"one start\""
						]
					}
				]
			}
		}
	}

}
