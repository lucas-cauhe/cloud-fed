define storage::ceph::monitor (
	$mon = $title,
	String $fsid,
	String $pub_net,
	String $cluster_net,
	Array[Hash] $monitors = [],
	Optional[String] $cluster_name = undef,
	Boolean $bootstrap = false,
	String $id
) {
	$cluster_name_ = common::unwrap_or($cluster_name, $storage::ceph::vars::cluster_name['10'])
	$mon_ipaddress = $monitors.filter |$v| { $v[hostname] == $mon }[0][ipaddress]
	$imageName = "netfull-ceph"

	if $id == '10' {
		$guest_vlan = $virt::containers::guest_vlan_ceph_10
	} else {
		$guest_vlan = $virt::containers::guest_vlan_ceph_20
	}
	ensure_resource('Virt::Container_file', $imageName, {  
		from => 'docker.io/library/debian:12',	
		run => [
			"apt-get update && apt install -y net-tools iproute2 iputils-ping procps wget gnupg software-properties-common",
			"wget -q -O- 'https://download.ceph.com/keys/release.asc' | apt-key add -",
			"apt-add-repository 'deb https://download.ceph.com/debian-reef/ bookworm main'",
			"apt-get install -y ceph ceph-mon ceph-mgr"
		]
	})
	
	if $bootstrap {
		$bootstrap_aware_instructions = [ 
					"ceph-authtool --create-keyring /etc/ceph/ceph.mon.keyring --gen-key -n mon. --cap mon 'allow *'",
					"ceph-authtool /etc/ceph/ceph.mon.keyring --import-keyring /etc/ceph/ceph.client.admin.keyring", 
					"mkdir -p /var/lib/ceph/bootstrap-osd",
					"ceph-authtool --create-keyring /var/lib/ceph/bootstrap-osd/ceph.keyring --gen-key -n client.bootstrap-osd --cap mon 'profile bootstrap-osd' --cap mgr 'allow r'",
					"ceph-authtool /etc/ceph/ceph.mon.keyring --import-keyring /var/lib/ceph/bootstrap-osd/ceph.keyring",
					"monmaptool --create --add ${monitors[0][hostname]} ${monitors[0][ipaddress]} --fsid $fsid /tmp/monmap",
		]
		$initial_members = $mon
		$mon_host = ["[v2:${monitors[0][ipaddress]}:3300/0,v1:${monitors[0][ipaddress]}:6789/0]"]
		$leader_mon_keyring = []
	} else {
		$bootstrap_aware_instructions = ["monmaptool --create --add ${monitors[0][hostname]} ${monitors[0][ipaddress]} --add ${monitors[1][hostname]} ${monitors[1][ipaddress]} --add ${monitors[2][hostname]} ${monitors[2][ipaddress]} --fsid $fsid /tmp/monmap"]
		$initial_members = $monitors.map |$m| { $m[hostname] }
		$mon_host = $monitors.map |$m| { "[v2:${m[ipaddress]}:3300/0,v1:${m[ipaddress]}:6789/0]" }
		$leader_mon_keyring = ["podman cp ${monitors[0][hostname]}:/etc/ceph/ceph.mon.keyring $mon:/etc/ceph"]

	}

	
	virt::podman_unit { "$mon.container":
		require => Virt::Container_file[$imageName],
		args => {
			unit_entry => {
				'Description' => "Ceph $id monitor $mon container"
			},
			container_entry => {
				'AddCapability' => 'NET_ADMIN NET_RAW IPC_LOCK',
				'ContainerName' => $mon,
				'Exec' => 'sleep infinity',
				'Image' => $imageName,
				'Network' => "pod_ceph_$id",
				'IP' => $mon_ipaddress,
				'Label' => '\"ceph\"',
				'HostName' => $mon
			},
			install_entry => {
				'WantedBy' => 'multi-user.target'
			},
			service_restart => true,

		}
	} -> 
	virt::container_provision { "${mon}_provision": 
		container_name => $mon,
		plan => [
			{
				"type" => "guest_file",
				"actions" => [
					{
						'path' => "/etc/ceph/${cluster_name_}.conf",
						'content' => epp('storage/ceph_conf', {
							'config' => {
								'global' => {
									'fsid' => $fsid,
									'mon_initial_members' => $initial_members,
									'mon_host' => join($mon_host, ' '),
									'public_network' => $pub_net,
									'cluster_network' => $cluster_net,
									'auth_cluster_required' => 'cephx',
									'auth_service_required' => 'cephx',
									'auth_client_required' => 'cephx',
									'osd_pool_default_size' => 3
								}
							}
						})
					}
				]
			},
			{
				"type" => "container",
				"actions" => ["podman cp /etc/$cluster_name_/ceph.client.admin.keyring $mon:/etc/ceph"] + $leader_mon_keyring
			},
			{
				"type" => "guest",
				"actions" => $guest_vlan +  [
					"ip route add default via 192.168.$id.254",
					]
					+ $bootstrap_aware_instructions + 
					[ "chown ceph:ceph /etc/ceph/ceph.mon.keyring",
					"mkdir /var/lib/ceph/mon/${cluster_name_}-$mon",
					"chown ceph:ceph /var/lib/ceph/mon/${cluster_name_}-$mon",
					"ceph-mon -c /etc/ceph/$cluster_name_.conf -n mon.$mon --setuser ceph --setgroup ceph --cluster $cluster_name_ --mkfs -i $mon --monmap /tmp/monmap --keyring /etc/ceph/ceph.mon.keyring",
					"cp /etc/ceph/ceph.mon.keyring /var/lib/ceph/mon/${cluster_name_}-${mon}/keyring",
					"ceph-mon -c /etc/ceph/$cluster_name_.conf -n mon.$mon --cluster $cluster_name_ -i $mon --mon-data /var/lib/ceph/mon/${cluster_name_}-${mon} --debug_ms 5"
				]
			}
			
		]
	}
}
