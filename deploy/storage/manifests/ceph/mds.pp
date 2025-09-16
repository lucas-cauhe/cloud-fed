define storage::ceph::mds(
	Optional[String] $fsid = undef,
	Optional[String] $cluster_name = undef,
	Hash $mon,
	String $ipaddress,
	String $id
) {
	$cluster_name_ = common::unwrap_or($cluster_name, $storage::ceph::vars::cluster_name[$id])
	$fsid_ = common::unwrap_or($fsid, $storage::ceph::vars::fsid[$id])
	
	if $id == '10' {
		$guest_vlan = $virt::containers::guest_vlan_ceph_10
	} else {
		$guest_vlan = $virt::containers::guest_vlan_ceph_20
	}
	#
	# Create local mds folder
	#
	exec { "/usr/bin/mkdir -p /etc/$cluster_name_/mds/$name":
	}->

	#
	# Create keyring
	#
	exec { "/usr/sbin/cephadm shell -m /etc/$cluster_name_:/etc/ceph -- ceph-authtool --create-keyring /etc/ceph/mds/$name/keyring --gen-key -n mds.$name":
	} ->

	#
	# Add it to the auth registry
	#
	exec { "/usr/sbin/cephadm shell -m /etc/$cluster_name_:/etc/ceph -- ceph auth add mds.$name osd 'allow rwx' mds 'allow *' mon 'allow profile mds' -i /etc/ceph/mds/$name/keyring":
	}->


	virt::podman_unit { "$name.container":
		args => {
			unit_entry => {
				'Description' => "Ceph $id mds $name container"
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

	virt::container_provision { "${name}_provision": 
		container_name => $name,
		plan => [
			{
				"type" => "guest_file",
				"actions" => [
					{
						'path' => "/etc/ceph/${cluster_name_}.conf",
						'content' => epp('storage/ceph_conf', {
							'config' => {
								'global' => {
									'fsid' => $fsid_,
									'mon_host' => $mon[ipaddress],
									'mon_initial_members' => $mon[hostname],
								},
								"mds.$name" => {
									'host' => "$name"
								}
							}
						})
					},
					
				]
			},
			{
				"type" => "guest",
				"actions" => [
					"mkdir -p /var/lib/ceph/mds/$cluster_name_-$name",
				] 
			},
			{
				"type" => "container",
				"actions" => [
					"podman cp /etc/$cluster_name_/mds/$name/keyring $name:/var/lib/ceph/mds/$cluster_name_-$name/keyring"
				]
			},
			{
				"type" => "guest",
				"actions" => $guest_vlan + [
					"ip route add default via 192.168.$id.254",
					"ceph-mds --cluster $cluster_name_ -i $name"
				]
			}
			
		]
	}
}
