# storage/manifests/ceph/rgw.pp
define storage::ceph::rgw (
    String $id,
    String $cluster_name,
    String $fsid,
    Hash $mon,
    String $ipaddress,
    Enum['master', 'slave'] $role = 'slave',
    Hash $rgw_options
) {

    #
    # Variables locales
    #
    notice("Bootstraping RGW: $name")
	$fsid_ = common::unwrap_or($fsid, $storage::ceph::vars::fsid[$id])
	$pwd = common::pwd()
	$scripts_path = "$pwd/deploy/$module_name/scripts"
    if $id == '10' {
        $guest_vlan = $virt::containers::guest_vlan_ceph_10
    } else {
        $guest_vlan = $virt::containers::guest_vlan_ceph_20
    }

    #
    # Create realm and zonegroup if role is set to master
    #
    if $role == 'master' {
        $zone_creation_role = 'master'
        notice("Creating new realm")
        exec { "/usr/sbin/cephadm shell -m /etc/$cluster_name:/etc/ceph -- radosgw-admin realm create --rgw-realm=${rgw_options[realm_name]} --default > /etc/$cluster_name/rgw.realm.${rgw_options[realm_name]}":
            refreshonly => true
        }->
        exec { "/usr/sbin/cephadm shell -m /etc/$cluster_name:/etc/ceph -- radosgw-admin zonegroup create --rgw-zonegroup=${rgw_options[zonegroup_name]} --endpoints=${rgw_options[zonegroup_address]} --master --default > /etc/$cluster_name/rgw.zonegroup.${rgw_options[zonegroup_name]}":
            refreshonly => true
        }->
        file { "/tmp/dummy-$name-$id":
            ensure => 'absent'
        }
    } else {
        $zone_creation_role = ""
        file { "/tmp/dummy-$name-$id":
            ensure => 'absent'
        }
    }

	#
	# Create `rgw-$id` ceph user
	#
    $user_keyring = "ceph.client.rgw-$id.keyring"
	storage::ceph::user { "rgw-$id":
        require => File["/tmp/dummy-$name-$id"],
		type => 'client',
		cluster_name => $cluster_name,
		caps => "mon 'allow rw' osd 'allow rwx'",
        output => $user_keyring
	}

	virt::podman_unit { "$name.container":
        require => Storage::Ceph::User["rgw-$id"],
		args => {
			unit_entry => {
				'Description' => "Ceph $id rgw $name container"
			},
			container_entry => {
				'AddCapability' => 'NET_ADMIN NET_BIND_SERVICE SYS_ADMIN NET_RAW IPC_LOCK',
				'ContainerName' => $name,
				'Exec' => 'sleep infinity',
				'Image' => 'netfull-ceph',
				'Network' => "pod_ceph_$id",
				'IP' => $ipaddress,
				'HostName' => $name,
                'Volume' => "/etc/$cluster_name/$user_keyring:/var/lib/ceph/radosgw/ceph-rgw-$id/keyring"
			},
			install_entry => {
				'WantedBy' => 'multi-user.target'
			},
			service_restart => true,
		}
	}->
    #
    # Aprovisionamiento y configuración de RGW
    #
	virt::container_provision { "${name}_provision":
		container_name => $name,
		plan => [
			{
            # ceph.conf
				"type" => "guest_file",
				"actions" => [
					{
						'path' => "/etc/ceph/$cluster_name.conf",
						'content' => epp('storage/ceph_conf', {
							'config' => {
								'global' => {
									'fsid' => $fsid_,
									'mon_host' => $mon[ipaddress],
									'mon_initial_members' => $mon[hostname],
									'public_network' => $storage::ceph::vars::network[$id][ceph_public_net],
								}
							}
						})
					},

				]
			},
            {
            # distribución de credenciales
                "type" => "container",
                "actions" => ["podman cp /etc/$cluster_name/ceph.client.admin.keyring $name:/etc/ceph"]
            },
			{
            # puesta en marcha
				"type" => "guest",
				"actions" => $guest_vlan + [
					"ip route add default via 192.168.$id.254",
                    "apt install -y radosgw",
                    "chown -R ceph:ceph /var/lib/ceph"
				]
			}

		]
	}->
	exec { "/usr/bin/ruby $scripts_path/rgw_zone_creation.rb $name $cluster_name $id $role ${rgw_options[zonegroup_name]} ${rgw_options[zone_name]} $ipaddress:7480":
		logoutput => true,
		refreshonly => true
	}

}
