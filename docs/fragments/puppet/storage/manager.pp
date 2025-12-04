# storage/manifests/ceph/manager.pp
define storage::ceph::manager(
	String $ipaddress,
	Hash $mon,
	Optional[String] $cluster_name = undef,
	Optional[String] $fsid = undef,
	String $id
) {

    #
    # Variables locales
    #
	$cluster_name_ = common::unwrap_or($cluster_name, $storage::ceph::vars::cluster_name[$id])
	$fsid_ = common::unwrap_or($fsid, $storage::ceph::vars::fsid[$id])

	if $id == '10' {
		$guest_vlan = $virt::containers::guest_vlan_ceph_10
	} else {
		$guest_vlan = $virt::containers::guest_vlan_ceph_20
	}

	#
	# Create manager keyring & caps
	#
	exec { "${name}-creation":
		command => "/usr/sbin/cephadm shell \\
	-m /etc/${cluster_name_}:/etc/ceph -- \\
	ceph auth get-or-create mgr.$name mon 'allow profile mgr' osd 'allow *' mds 'allow *' > /etc/$cluster_name_/ceph.mgr.$name.keyring"
	}

	#
	# Create manager container
	#
	virt::podman_unit { "$name.container":
		args => {
			unit_entry => {
				'Description' => "Ceph $id manager $name container"
			},
			container_entry => {
				'AddCapability' => 'NET_ADMIN NET_RAW IPC_LOCK',
				'ContainerName' => $name,
				'Exec' => 'sleep infinity',
				'Image' => 'netfull-ceph',
				'Network' => "pod_ceph_$id",
				'IP' => $ipaddress,
				'Label' => '\"ceph\"',
				'HostName' => $name,
			},
			install_entry => {
				'WantedBy' => 'multi-user.target'
			},
			service_restart => true,
		}
	}->

	#
	# Add keyring and start manager
	#
	virt::container_provision { "${name}_provision":
		require => Exec["${name}-creation"],
		container_name => $name,
		plan => [
			{
            # ceph.conf
				"type" => "guest_file",
				"actions" => [
					{
						'path' => "/etc/ceph/${cluster_name_}.conf",
						'content' => epp('storage/ceph_conf', {
							'config' => {
								'global' => {
									'fsid' => $fsid_,
									'mon_host' => $mon[ipaddress],
									'mon_initial_members' => $mon[hostname]
								}
							}
						})
					}
				]
			},
			{
            # directorio de keyring
				"type" => "guest",
				"actions" => ["mkdir -p /var/lib/ceph/mgr/${cluster_name_}-$name"]
			},
			{
            # distribución de claves
				"type" => "container",
				"actions" => [
					"podman cp /etc/${cluster_name_}/ceph.mgr.$name.keyring $name:/etc/ceph",
					"podman cp /etc/${cluster_name_}/ceph.mgr.$name.keyring $name:/var/lib/ceph/mgr/${cluster_name_}-$name/keyring"
				]
			},
			{
            # configuración de red y puesta en marcha
				"type" => "guest",
				"actions" => $guest_vlan + [
					"ip route add default via 192.168.$id.254",
					"ceph-mgr -i $name -c /etc/ceph/$cluster_name_.conf -n mgr.$name --cluster $cluster_name_ --setuser ceph --setgroup ceph"
				]
			}

		]
	}
}
