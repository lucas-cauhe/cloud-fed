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
	# Adding slaves
	#

	#
	# Stop slaves One in HA 
	#
	$slaves.each |$slave| {
		$virt::containers::oned_services[$slave].each |$slave_service| {
			exec {"/usr/bin/podman exec ${slave_service[hostname]} one stop":
			}
		}
	}

	#
	# Make master db snapshot
	#
	exec { "federated-snap":
		command => "/usr/bin/podman exec $master_container onedb backup --federated -S ${virt::containers::one_db_ip['10']} -t mysql -u oneadmin_10 -p $db_passwd -d opennebula_10 /var/lib/one/one.db"
	}

	#
	# Create zones from master
	#
	$slaves.each |$slave| {
		file { "/tmp/$slave-zone.tmpl":
			ensure => 'present',
			content => "NAME = zone-$slave
			ENDPOINT = ${virt::containers::one_vip[$slave]}"
		}->
		exec {"/usr/bin/podman cp /tmp/$slave-zone.tmpl $master_container:/tmp/$slave-zone.tmpl":
		}->
		exec { "/usr/bin/podman exec $master_container onezone create /tmp/$slave-zone.tmpl > /tmp/$slave-zone-id":
			require => Exec["federated-snap"]
		}
	}

	#
	# Copy db & auth files
	#
	$slaves.each |$slave| {
		exec { "/usr/bin/podman cp $master_container:/var/lib/one/one.db ${virt::containers::oned_services[$slave][0][hostname]}:/tmp/one.db":
		}->	
		exec { "$slave-db-restore":
			command => "/usr/bin/podman exec ${virt::containers::oned_services[$slave][0][hostname]} onedb restore --federated -S $virt::containers::one_db_ip -t mysql -u oneadmin_$slave -p ${env['MARIADB_ONE_${slave}_PASSWD']} -d opennebula_$slave /var/lib/one/one.db"
		}
		$virt::containers::oned_services[$slave].each |$slave_service| {
			exec { "/usr/bin/podman cp $master_container:/var/lib/one/.one/one_auth ${slave_service[hostname]}:/var/lib/one/.one/one_auth":
			} 
			virt::container_provision { "${slave_service[hostname]} fed provision":
				require => Exec["$slave-db-restore"],
				container_name => $slave_service[hostname],
				plan => [
					{
						"type" => "guest_file",
						"actions" => [
							{
								'path' => '/etc/one/oned.conf',
								'replace' => {
									'src' => 'ZONE_ID    = 0',
									'dest' => 'ZONE_ID    = 100'
								}
							},
							{
								'path' => '/etc/one/oned.conf',
								'replace' => {
									'src' => 'MASTER_ONED  = ""',
									'dest' => "MASTER_ONED  = \"http://${virt::containers::one_vip['10']}:2633/RPC2\""
								}
							},

						]
					},
					{
						"type" => "guest",
						"actions" => ["su oneadmin - -c \"one start\""]
					}
				]
			}
		}
	}
	
}
