define virt::services::opennebula::oned (
	Array[Hash] $kvm_nodes = [{'hostname' => 'node1', 'ipaddress' => '10.0.13.71'}],
	Hash $leader,
	Hash $oned,
	String $fed_id
){
	# Container declaration

	# quitar los session de pam
	# pasar a root y oneadmin la clave de /var/lib/one/.ssh/id_rsa.pub como root
	$env = $facts['env_vars']
	$imageName = "almalinux_oned"
	if $fed_id == "10" {
		$connect_to_internet = [
			"ip route add default via 192.168.10.254 dev $virt::containers::vlan_iface_one_10"
		]
		$db_passwd = $env['MARIADB_ONE_10_PASSWD']
		$guest_vlan = $virt::containers::guest_vlan_one_10
	} else {
		$connect_to_internet = [
			"ip route add default via 192.168.20.254 dev $virt::containers::vlan_iface_one_20"
		]
		$db_passwd = $env['MARIADB_ONE_20_PASSWD']
		$guest_vlan = $virt::containers::guest_vlan_one_20
	}

	$fed_mode = $fed_id ? {
		'10' => "MASTER",
		default => "SLAVE"
	}

	$db_config = @(END)
DB = [  BACKEND = "mysql",
		SERVER  = %deployment[:virt][:services]["one_db"][:network][:"pod_one_<%= $id %>"][:ipaddress]%,
		PORT    = 0,
		USER    = "oneadmin_<%= $id %>", 
		PASSWD  = "<%= $passwd %>",
		DB_NAME = "<%= $db_name %>",
		CONNECTIONS = 25,
		COMPARE_BINARY = "no" ]
	| - END

	$raft_leader_hooks = @(END)
	RAFT_LEADER_HOOK = [
	     COMMAND = "raft/vip.sh",
	     ARGUMENTS = "leader %network[:"pod_one_<%= $id %>"][:interface]% <%= $virtual_ip %>/24"
	]

	# Executed when a server transits from leader->follower
	RAFT_FOLLOWER_HOOK = [
	    COMMAND = "raft/vip.sh",
	    ARGUMENTS = "follower %network[:"pod_one_<%= $id %>"][:interface]% <%= $virtual_ip %>/24"
	]
	| - END
	
	ensure_resource('Virt::Container_file', $imageName, {
		from => 'docker.io/library/almalinux:9',	
		cp => [
			"./opennebula.repo /etc/yum.repos.d/opennebula.repo"
		],
		run => [
			"dnf update -y && dnf install -y sudo net-tools iproute 'dnf-command(config-manager)'",
			"dnf config-manager --set-enabled crb",
			"dnf clean all",
			"dnf makecache",
			"dnf -y install epel-release",
			"dnf makecache",
			"groupadd sudo",
			"dnf -y install mariadb opennebula",
			"usermod -a -G sudo oneadmin"
		]
	})
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
				"type" => "container",
				"actions" => [
					"podman cp $virt::containers::scripts_path/mock_service.sh ${oned[hostname]}:/sbin/service"
				]
			},
			{
				"type" => "guest",
				"actions" => $guest_vlan + $connect_to_internet 
			},
			{
				"type" => "guest_file",
				"actions" => [
					{
						'path' => '/etc/one/oned.conf',
						'replace' => {
							'src' => 'DB = [ BACKEND = "sqlite",
		       TIMEOUT = 2500 ]',
							'dest' => inline_epp($db_config, {'passwd' => $db_passwd, 'db_name' => 'opennebula_10', 'id' => $fed_id})
						}
					},
					{
						'path' => '/var/lib/one/.one/one_auth',
						'content' => "oneadmin:oneadmin_$fed_id",
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
				"onlyif" => $oned[role] == 'leader',
				"actions" => [
					"%reload% chmod +x /sbin/service",
					"su oneadmin - -c \"one start\"",
					"sleep 5",
					"onezone server-add 0 --name ${oned[hostname]} --rpc http://${oned[ipaddress]}:2633/RPC2",
					"sleep 5",
					"one stop"
				]
			},

			#
			# Follower setup 
			#
			{
				"type" => "container",
				"onlyif" => $oned[role] == 'follower',
				"actions" => [
					"podman exec ${leader[hostname]} onedb backup -S ${virt::containers::one_db_ip[$fed_id]} -t mysql -u oneadmin_$fed_id -p $db_passwd -d opennebula_$fed_id /var/lib/one/${oned[hostname]}.sql",
					"podman cp ${leader[hostname]}:/var/lib/one/${oned[hostname]}.sql ${oned[hostname]}:/tmp",
					"podman exec ${oned[hostname]} rm -rf /var/lib/one/.one",
					"podman cp ${leader[hostname]}:/var/lib/one/.one ${oned[hostname]}:/var/lib/one",
					"podman exec ${oned[hostname]} chown -R oneadmin:oneadmin /var/lib/one/.one",
					"podman exec ${oned[hostname]} onedb restore -f -u oneadmin_$fed_id -p $db_passwd -d opennebula_$fed_id -S ${virt::containers::one_db_ip[$fed_id]} -t mysql /tmp/${oned[hostname]}.sql",
					"until podman exec ${leader[hostname]} onezone show -j 0 | grep '\"STATE\": \"3\"'; do sleep 1; done", # if no leader is found the command below fails
					"podman exec ${leader[hostname]} onezone server-add 0 --name ${oned[hostname]} --rpc http://${oned[ipaddress]}:2633/RPC2"
				]
			},

			#
			# HA configuration
			#
			{
				"type" => "guest_file",
				"actions" => [
					{
						'path' => '/tmp/update_zone.one',
						'content' => "ENDPOINT=\"http://${virt::containers::one_vip[$fed_id]}:2633/RPC2\""
					},
					{
						'path' => '/etc/one/oned.conf',
						'replace' => {
							'src' => 'SERVER_ID     = -1',
							'dest' => "SERVER_ID     = ${oned[id]}"
						}
					},
					{
						'path' => '/etc/one/oned.conf',
						'replace' => {
							'src' => 'MODE     = "STANDALONE"',
							'dest' => "MODE     = \"$fed_mode\""
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
						'append' => inline_epp($raft_leader_hooks, {'virtual_ip' => $virt::containers::one_vip[$fed_id], 'id' => $fed_id})
					}
				] 
			},
			{
				"type" => "guest",
				"actions" => ["su oneadmin - -c \"one start\""]
			}, 

			# wait for server to become leader 
			{
				"type" => "container",
				"actions" => 
					["until podman exec ${leader[hostname]} onezone show -j 0 | grep '\"STATE\": \"3\"'; do sleep 1; done"
					]
			},
			{	
				"type" => "guest",
				"onlyif" => $fed_id == '10' and $oned[role] == 'leader',
				"actions" => ["onezone update 0 /tmp/update_zone.one", "su oneadmin - -c \"one restart\""]
			},

			# wait for server to become available
			{
				"type" => "container",
				"actions" => 
					["until podman exec ${leader[hostname]} onezone show -j 0 | grep '\"STATE\": \"3\"'; do sleep 1; done"
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

			#
			# Install ceph tools 
			#
			{
				"type" => "guest",
				"actions" => [
					"curl --silent --remote-name https://download.ceph.com/rpm-reef/el9/noarch/cephadm",
					"chmod +x cephadm",
					"cp cephadm /usr/bin",
					"cephadm add-repo --version 19.2.2", # se fija la versión por problema openssl v3.4
					"cephadm install ceph-common"
				] 
			},
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
