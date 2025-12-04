# storage/manifests/ceph/osd.pp
define storage::ceph::osd(
	Optional[String] $fsid = undef,
	Optional[String] $cluster_name = undef,
	Hash $mon,
	String $ipaddress,
	String $cluster_ipaddress,
	String $id
) {
    #
    # Variables locales
    #
	$cluster_name_ = common::unwrap_or($cluster_name, $storage::ceph::vars::cluster_name[$id])
	$fsid_ = common::unwrap_or($fsid, $storage::ceph::vars::fsid[$id])
	$osd_fsid = storage::uuid()

	if $id == '10' {
		$guest_vlan = $virt::containers::guest_vlan_ceph_10
		$cluster_vlan = $virt::containers::guest_vlan_stor_10
	} else {
		$guest_vlan = $virt::containers::guest_vlan_ceph_20
		$cluster_vlan = $virt::containers::guest_vlan_stor_20
	}

    #
    # Instalación de paquetes para FS XFS
    #
	ensure_resource ('package', 'xfsprogs', {
		ensure => 'installed'
	})
    #
    # Cargar módulo XFS del kernel
    #
	ensure_resource ('exec', 'load-xfs', {
		require => Package['xfsprogs'],
		command => '/usr/sbin/modprobe xfs'
	})

	#
	# Ensure lvm is created & clean
	# Needs to be checked at run time because the lvm might be created on the same manifest run and in compile time would
	# fails to the eyes of facter
	#
	$pwd = common::pwd()
	$scripts_path = "$pwd/deploy/$module_name/scripts"
	exec { "/usr/bin/ruby $scripts_path/prepare_lvm.rb $name $cluster_name_ $osd_fsid ${mon[hostname]}":
		require => Exec['load-xfs'],
		logoutput => true,
		refreshonly => true
	} ->

	#
	# Bootstrap OSD
	#
	virt::podman_unit { "$name.container":
		args => {
			unit_entry => {
				'Description' => "Ceph $id osd $name container"
			},
			container_entry => {
				'AddCapability' => 'NET_ADMIN NET_BIND_SERVICE SYS_ADMIN NET_RAW IPC_LOCK',
				'ContainerName' => $name,
				'Exec' => 'sleep infinity',
				'Image' => 'netfull-ceph',
				'Network' => "pod_ceph_$id",
				'IP' => $ipaddress,
				'HostName' => $name,
				'Volume' => "/etc/$cluster_name_/osd/$name:/var/lib/ceph/osd/ceph-$name",
				'EnvironmentFile' => "/tmp/env-$name",
				'Label' => '\"ceph\"',
				'Ulimit' => 'nofile=1048576:1048576'
			},
			install_entry => {
				'WantedBy' => 'multi-user.target'
			},
			service_restart => true,
		}
	}->

    #
    # Aprovisionamiento y configuración del OSD
    #
	virt::container_provision { "${name}_provision":
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
									'mon_initial_members' => $mon[hostname],
									'public_network' => $storage::ceph::vars::network[$id][ceph_public_net],
									'cluster_network' => $storage::ceph::vars::network[$id][ceph_cluster_net]
								}
							}
						})
					},

				]
			},
			{
                # red de replicación
				"type" => "container",
				"actions" => [
					"podman network connect --ip $cluster_ipaddress pod_stor_$id $name"
				]
			},
			{
                # puesta en marcha
				"type" => "guest",
				"actions" => $guest_vlan + $cluster_vlan + [
					"ip route add default via 192.168.$id.254",
					"apt install udev", # needed by ceph-volume
					join(['bash -c "ceph-osd -c /etc/ceph/', $cluster_name_, '.conf -i \$ID --mkfs --osd-data /var/lib/ceph/osd/ceph-', $name, ' --osd-uuid ', $osd_fsid, '"'], ''),
					"chown -R ceph:ceph /var/lib/ceph/osd/ceph-$name",
					join(['bash -c "ceph-osd -c /etc/ceph/', $cluster_name_, '.conf -i \$ID -n osd.\$ID --cluster ', $cluster_name_, ' --setuser ceph --setgroup ceph --debug_ms 10 --osd-data /var/lib/ceph/osd/ceph-', $name, '"'], '')
				]
			}

		]
	}
}
