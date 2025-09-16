define virt::services::opennebula::db {
	# Container declaration

	$env = $facts['env_vars']


	$sql_query_base = "mariadb -u root -p${env['MARIADB_ROOT_PASSWD']} -e \""
	$sql_query_end = ";\""

	$db_setup = [
		"$sql_query_base DROP DATABASE IF EXISTS opennebula_10$sql_query_end", 
		"$sql_query_base DROP DATABASE IF EXISTS opennebula_20$sql_query_end", 
		"$sql_query_base CREATE USER IF NOT EXISTS oneadmin_20@'192.168.20.%' IDENTIFIED BY '${env['MARIADB_ONE_20_PASSWD']}'$sql_query_end",
		"$sql_query_base CREATE USER IF NOT EXISTS oneadmin_10@'192.168.10.%' IDENTIFIED BY '${env['MARIADB_ONE_10_PASSWD']}'$sql_query_end",
		"$sql_query_base CREATE DATABASE opennebula_10$sql_query_end", 
		"$sql_query_base CREATE DATABASE opennebula_20$sql_query_end", 
		"$sql_query_base GRANT ALL PRIVILEGES ON opennebula_10.* TO 'oneadmin_10'@'192.168.10.%'$sql_query_end",
		"$sql_query_base GRANT ALL PRIVILEGES ON opennebula_20.* TO 'oneadmin_20'@'192.168.20.%'$sql_query_end",
		"$sql_query_base SET GLOBAL TRANSACTION ISOLATION LEVEL READ COMMITTED$sql_query_end"
	]

	#
	# Prepare rbd device on the host for attaching opennebula db
	#
	storage::ceph::rbd { "one_db":
		conf => "/etc/ceph-10",
		pool => "db",
		image => "one_db",
		size => "20G",
		mountpoint => "/opt/one_db"
	}->
	virt::podman_unit { "one_db.container":
		args => {
			unit_entry => {
				'Description' => 'one_db container'
			},
			container_entry => {
				'AddCapability' => 'NET_ADMIN',
				'ContainerName' => 'one_db',
				'Image' => 'docker.io/library/mariadb:latest',
				'Network' => 'pod_one_10',
				'IP' => $virt::containers::one_db_ip['10'],
				'Label' => '\"one\"',
				'Environment' => ["MARIADB_ROOT_PASSWORD=${env['MARIADB_ROOT_PASSWD']}"],
				'Volume' => '/opt/one_db:/var/lib/mysql'
			},
			install_entry => {
				'WantedBy' => 'multi-user.target'
			},
			service_restart => true
		}
	}->

	# Container provisioning
	virt::container_provision { "one_db_provision":
		container_name => "one_db",
		plan => [
			{
				"type" => "container",
				"actions" => [
					"until podman logs one_db 2>&1 | grep \"ready for connections\"; do sleep 1; done", # wait for mariadb to be ready 
					"podman network connect --ip ${virt::containers::one_db_ip["20"]} pod_one_20 one_db"
				]
			},
			{
				"type" => "guest",
				"actions" => $virt::containers::guest_vlan_one_10 + $virt::containers::guest_vlan_one_20 + $db_setup
			}
		]
	}

}
