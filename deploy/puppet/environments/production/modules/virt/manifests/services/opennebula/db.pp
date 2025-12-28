define virt::services::opennebula::db (
    String $fed_id,
	String $server_name
) {
	# Container declaration

    $id = split($server_name, '_')[1]
	$container_name = "one-db-$id-$fed_id"
	$mountpoint = "/opt/$container_name"
    $db_root_pass = lookup('opennebula', Hash, 'deep')[db_config][root_passwd]


	$sql_query_base = "mariadb -u root -p$db_root_pass -e \""
	$sql_query_end = ";\""
    $db_pass = lookup('opennebula', Hash, 'deep')[db_config][one_passwd]

	$db_setup = [
		"$sql_query_base DROP DATABASE IF EXISTS opennebula$sql_query_end",

		"$sql_query_base CREATE USER IF NOT EXISTS oneadmin@'192.168.$fed_id.%' IDENTIFIED BY '$db_pass'$sql_query_end",

		"$sql_query_base CREATE DATABASE opennebula$sql_query_end",

		"$sql_query_base GRANT ALL PRIVILEGES ON opennebula.* TO 'oneadmin'@'192.168.$fed_id.%'$sql_query_end",

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
		cluster_name => "ceph-$fed_id",
		pool => "one-db-$fed_id",
		image => "db-$id",
		size => "2G",
		mountpoint => $mountpoint,
	}->
	virt::podman_unit { "$container_name.container":
		args => {
			unit_entry => {
				'Description' => "one_db $id-$fed_id container"
			},
			container_entry => {
				'AddCapability' => 'NET_ADMIN',
				'ContainerName' => $container_name,
				'Image' => 'docker.io/library/mariadb:latest',
				'Network' => "pod_public_$fed_id",
				'IP' => lookup('opennebula')[db][$id],
				'Environment' => ["MARIADB_ROOT_PASSWORD=$db_root_pass"],
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
					"%expect[0.0.0.0:3306]% podman exec $container_name ss -tulpn",
				]
			},
			{
				"type" => "guest",
				"actions" => $db_setup
			}
		]
	}

}
