define virt::services::opennebula::oned (
	Array[Hash] $kvm_nodes = [{'hostname' => 'node1', 'ipaddress' => '10.0.13.71'}],
	Hash $leader,
	Hash $oned,
	String $fed_id,
    String $zone_id,
    Boolean $ha = true,
    Optional[String] $master_ip = undef,
){
	# Container declaration

	# quitar los session de pam
	# pasar a root y oneadmin la clave de /var/lib/one/.ssh/id_rsa.pub como root
	$env = $facts['env_vars']
	$imageName = "almalinux_oned"
    $deploy_id = split($oned[hostname], '_')[1]
    $db_passwd = $env['MARIADB_ONE_PASSWD']
	if $fed_id == "10" {
		$connect_to_internet = [
			"ip route add default via 192.168.10.254 dev $virt::containers::vlan_iface_one_10"
		]
		$guest_vlan = $virt::containers::guest_vlan_one_10
	} else {
		$connect_to_internet = [
			"ip route add default via 192.168.20.254 dev $virt::containers::vlan_iface_one_20"
		]
		$guest_vlan = $virt::containers::guest_vlan_one_20
	}

	$db_config = @(END)
DB = [  BACKEND = "mysql",
		SERVER  = <%= $ipaddress %>,
		PORT    = 0,
		USER    = "oneadmin",
		PASSWD  = "<%= $passwd %>",
		DB_NAME = "opennebula",
		CONNECTIONS = 25,
		COMPARE_BINARY = "no" ]
	| - END


	ensure_resource('Virt::Container_file', $imageName, {
		from => 'docker.io/library/almalinux:9',
		cp => [
			"./opennebula.repo /etc/yum.repos.d/opennebula.repo"
		],
		run => [
		#
		# Opennebula installation
		#
			"dnf update -y && dnf install -y sudo net-tools iproute 'dnf-command(config-manager)'",
			"dnf config-manager --set-enabled crb",
			"dnf clean all",
			"dnf makecache",
			"dnf -y install epel-release",
			"dnf makecache",
			"groupadd sudo",
			"dnf -y install mariadb opennebula",
			"usermod -a -G sudo oneadmin",
		#
		# Ceph tools installation
		#
			"curl --silent --remote-name https://download.ceph.com/rpm-reef/el9/noarch/cephadm",
			"chmod +x cephadm",
			"./cephadm add-repo --version 19.2.2", # se fija la versión por problema openssl v3.4
			"./cephadm install ceph-common"
		]
	})
    #
    # Definición del contenedor
    #
	virt::podman_unit { "${oned[hostname]}.container":
		require => Virt::Container_file[$imageName],
		args => {
			unit_entry => {
				'Description' => '${oned[hostname]} container'
			},
			container_entry => {
				'AddCapability' => 'NET_ADMIN NET_RAW IPC_LOCK',
				'ContainerName' => $oned[hostname],
				'Image' => $imageName,
				'Network' => "pod_one_$fed_id",
				'Exec' => 'sleep infinity',
				'IP' => $oned[ipaddress],
				'Label' => '\"one\"',
				'HostName' => $oned[hostname]
			},
			install_entry => {
				'WantedBy' => 'multi-user.target'
			},
			service_restart => true
		}
	}->

	# Container provisioning
	virt::container_provision { "${oned[hostname]}_provision":
		container_name => $oned[hostname],
		plan => [
			{
            # Parche de systemd en contenedor
				"type" => "container",
				"actions" => [
					"podman cp $virt::containers::scripts_path/mock_service.sh ${oned[hostname]}:/bin/service"
				]
			},
			{
            # Configuración de red
				"type" => "guest",
				"actions" => $guest_vlan + $connect_to_internet
			},
			{
            # oned.conf
				"type" => "guest_file",
				"actions" => [
					{
						'path' => '/etc/one/oned.conf',
						'replace' => {
							'src' => 'DB = [ BACKEND = "sqlite",
		       TIMEOUT = 2500 ]',
							'dest' => inline_epp($db_config, {'passwd' => $db_passwd, 'ipaddress' => $virt::containers::one_db_ip[$fed_id][$deploy_id]})
						}
					},
					{
						'path' => '/etc/one/oned.conf',
						'replace' => {
							'src' => 'VM_RESTRICTED_ATTR = "RAW/DATA"',
							'dest' => '#VM_RESTRICTED_ATTR = "RAW/DATA"',
						}
					},
					{
						'path' => '/var/lib/one/.one/one_auth',
						'content' => "oneadmin:oneadmin",
						'owner' => 'oneadmin:oneadmin'
					},
					{
						'path' => '/etc/sudoers',
						'append' => '%sudo ALL=(ALL) NOPASSWD: ALL'
					}
				]
			},

			#
			# Leader initial setup
			#

			#
			# Start oned daemon and add server in standalone mode
			#
			{
				"type" => "guest",
				"actions" => [
					"%reload% chmod +x /bin/service",
					"su oneadmin - -c \"one start\"",
				]
			},
			{
				"type" => "container",
				"actions" =>
					[
					"%expect[0.0.0.0:2633]% podman exec ${oned[hostname]} ss -tulpn",
					]
			},
			{
				"type" => "guest",
				"onlyif" => $ha and $oned[role] == 'leader',
				"actions" => [
					"onezone server-add $zone_id --name ${oned[hostname]} --rpc http://${oned[ipaddress]}:2633/RPC2",
					"one stop"
				]
			},

			#
			# Follower setup
			#
			{
				"type" => "container",
				"onlyif" => $ha and $oned[role] == 'follower',
				"actions" => [
                    "podman exec ${oned[hostname]} one stop",
					"%expect[XML-RPC server stopped]% podman exec ${oned[hostname]} cat /var/log/one/oned.log", # ensure it is stopped
					"podman exec ${leader[hostname]} onedb backup -S ${virt::containers::one_db_ip[$fed_id][$deploy_id]} -t mysql -u oneadmin -p $db_passwd -d opennebula -f /var/lib/one/nebula_backup.sql",
					"podman cp ${leader[hostname]}:/var/lib/one/nebula_backup.sql ${oned[hostname]}:/tmp",
					"podman exec ${oned[hostname]} rm -rf /var/lib/one/.one",
					"podman cp ${leader[hostname]}:/var/lib/one/.one ${oned[hostname]}:/var/lib/one",
					"podman exec ${oned[hostname]} chown -R oneadmin:oneadmin /var/lib/one/.one",
					"podman exec ${oned[hostname]} onedb restore -f -u oneadmin -p $db_passwd -d opennebula -S ${virt::containers::one_db_ip[$fed_id][$deploy_id]} -t mysql /tmp/nebula_backup.sql",
					"%expect[<STATE>3</STATE>]% podman exec ${leader[hostname]} onezone show -x $zone_id", # if no leader is found the command below fails
					"podman exec ${leader[hostname]} onezone server-add $zone_id --name ${oned[hostname]} --rpc http://${oned[ipaddress]}:2633/RPC2"
				]
			},

			#
			# HA configuration
			#
			{
				"type" => "guest_file",
                "onlyif" => $ha,
				"actions" => [
					{
						'path' => '/etc/one/oned.conf',
						'replace' => {
							'src' => 'SERVER_ID     = -1',
							'dest' => "SERVER_ID     = ${oned[id]}"
						}
					},
					{
						'path' => '/etc/one/monitord.conf',
						'replace' => {
							'src' => 'MONITOR_ADDRESS = "auto"',
							'dest' => "MONITOR_ADDRESS = \"${virt::containers::one_vip[$fed_id]}\""
						}
					},
					{
						'path' => '/etc/one/oned.conf',
						'append' => inline_epp($virt::containers::raft_leader_hooks, {'virtual_ip' => $virt::containers::one_vip[$fed_id], 'id' => $fed_id})
					}
				]
			},

            #
            # Add additional config if in slave zone
            #
            {
				"type" => "guest_file",
                "onlyif" => $zone_id != undef and $master_ip != undef,
				"actions" => [
					{
						'path' => '/etc/one/oned.conf',
						'replace' => {
                            'src' => "\"STANDALONE\"",
                            'dest' => "\"SLAVE\""
						}
					},
                    {
                        'path' => '/etc/one/oned.conf',
                        'replace' => {
                            'src' => "ZONE_ID       = 0",
                            'dest' => "ZONE_ID       = $zone_id"
                        }
                    },
                    {
                        'path' => '/etc/one/oned.conf',
                        'replace' => {
                            'src' => "MASTER_ONED   = \"\"",
                            'dest' => "MASTER_ONED   = \"http://$master_ip:2633/RPC2\""
                        }
                    },
                ]
			},
			{
				"type" => "guest",
                "onlyif" => $ha,
				"actions" => ["su oneadmin - -c \"one start\""]
			},

			# wait for server to become available & there is a leader
			{
				"type" => "container",
                "onlyif" => $ha,
				"actions" =>
					[
					"%expect[0.0.0.0:2633]% podman exec ${leader[hostname]} ss -tulpn",
					"%expect[<STATE>3</STATE>]% podman exec ${leader[hostname]} onezone show -x $zone_id"
					]
			},



			#
			# Distribute ssh key to nodes
			#
			{
				"type" => "container",
				"actions" => [
					"podman cp ${oned[hostname]}:/var/lib/one/.ssh/id_rsa.pub /var/lib/one/id_rsa.pub",
					"cat /var/lib/one/id_rsa.pub >> /var/lib/one/.ssh/authorized_keys",
					"rm /var/lib/one/id_rsa.pub"
				],
			},

			#
			# Distribute ssh key to frontal
			#
			{
				"type" => "container",
				"actions" => [
					"podman cp ${oned[hostname]}:/var/lib/one/.ssh/authorized_keys /var/lib/one/authorized_keys",
					"cat /var/lib/one/.ssh/id_rsa.pub >> /var/lib/one/authorized_keys",
					"podman cp /var/lib/one/authorized_keys ${oned[hostname]}:/var/lib/one/.ssh/authorized_keys ",
					"podman exec ${oned[hostname]} chown oneadmin:oneadmin /var/lib/one/.ssh/authorized_keys",
					"rm /var/lib/one/authorized_keys"
				],
			},

			#
			# Add KVM Hosts
			#
			{
				"type" => "guest",
				"onlyif" => $oned[role] == 'leader',
				"actions" => $kvm_nodes.map |$node| { "onehost create ${node[ipaddress]} -i kvm -v kvm" }
			},

			#
			# Ceph definition
			#

			{
				"type" => "guest_file",
				"actions" => [
					{
						'path' => "/etc/ceph/${storage::ceph::vars::cluster_name[$fed_id]}.conf",
						'content' => epp('storage/ceph_conf', {
							'config' => {
								'global' => {
									'fsid' => $storage::ceph::vars::fsid[$fed_id],
									'mon_host' => $storage::ceph::vars::network[$fed_id][mon][0][ipaddress],
									'rbd_default_format' => 2
								}
							}
						})
					}
				]
			}
		]
	}
}
