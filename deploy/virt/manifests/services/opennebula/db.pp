define virt::services::opennebula::db (
	String $id
) {
	# Container declaration

	$env = $facts['env_vars']
	$container_name = "one-db-$id"
	$mountpoint = "/opt/$container_name"


	$sql_query_base = "mariadb -u root -p${env['MARIADB_ROOT_PASSWD']} -e \""
	$sql_query_end = ";\""

	$db_pass_10 = $env['MARIADB_ONE_10_PASSWD']
	$db_pass_20 = $env['MARIADB_ONE_20_PASSWD']

	$db_setup = [
		"$sql_query_base DROP DATABASE IF EXISTS opennebula_10$sql_query_end",
		"$sql_query_base DROP DATABASE IF EXISTS opennebula_20$sql_query_end",

		"$sql_query_base CREATE USER IF NOT EXISTS oneadmin_10@'192.168.10.%' IDENTIFIED BY '$db_pass_10'$sql_query_end",
		"$sql_query_base CREATE USER IF NOT EXISTS oneadmin_20@'192.168.20.%' IDENTIFIED BY '$db_pass_20'$sql_query_end",

		"$sql_query_base CREATE DATABASE opennebula_10$sql_query_end",
		"$sql_query_base CREATE DATABASE opennebula_20$sql_query_end",

		"$sql_query_base GRANT ALL PRIVILEGES ON opennebula_10.* TO 'oneadmin_10'@'192.168.10.%'$sql_query_end",
		"$sql_query_base GRANT ALL PRIVILEGES ON opennebula_20.* TO 'oneadmin_20'@'192.168.20.%'$sql_query_end",

		"$sql_query_base SET GLOBAL TRANSACTION ISOLATION LEVEL READ COMMITTED$sql_query_end"
	]


	#
	# Prepare rbd device on the host for attaching opennebula db
	#
	file { $mountpoint:
		ensure => 'directory',
		mode => "0755",
		owner => "dnsmasq",
		group => "systemd-journal"
	} ->
	storage::ceph::rbd { $container_name:
		cluster_name => 'ceph-10',
		pool => "one-db",
		image => "db-$id",
		size => "2G",
		mountpoint => $mountpoint,
	}->
	virt::podman_unit { "$container_name.container":
		args => {
			unit_entry => {
				'Description' => "one_db $id container"
			},
			container_entry => {
				'AddCapability' => 'NET_ADMIN',
				'ContainerName' => $container_name,
				'Image' => 'docker.io/library/mariadb:latest',
				'Network' => "pod_one_10",
				'IP' => $virt::containers::one_db_ip['10'][$id],
				'Environment' => ["MARIADB_ROOT_PASSWORD=${env['MARIADB_ROOT_PASSWD']}"],
				'Volume' => "$mountpoint:/var/lib/mysql"
			},
			install_entry => {
				'WantedBy' => 'multi-user.target'
			},
			service_restart => true
		}
	}->

	# Container provisioning
	virt::container_provision { "${container_name}-provision":
		container_name => $container_name,
		plan => [
			{
				"type" => "container",
				"actions" => [
					 # wait for mariadb to be ready
					"%expect[ready for connections]% podman logs $container_name 2>&1",
					"podman network connect --ip ${virt::containers::one_db_ip['20'][$id]} pod_one_20 $container_name"
				]
			},
			{
				"type" => "guest",
				"actions" => $virt::containers::guest_vlan_one_10 + $virt::containers::guest_vlan_one_20 + $db_setup
			}
		]
	}

}
