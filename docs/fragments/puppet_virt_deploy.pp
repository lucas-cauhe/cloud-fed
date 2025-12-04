class virt {
    # Despliegue de la red Podman
    [...]
    # Despliegue del gateway
	class {'virt::services::gateway':
		require => $virt::containers::deployment_units.map |$du| { Virt::Podman_network["network-$du"] },
	}
    # Despliegue de clusters ceph
	$virt::containers::deployment_units.each |$id| {
		storage::ceph {"ceph-$id":
			require => Class["virt::services::gateway"],
			id => $id
		}
	}
    # Creación cliente s3
    [...]
    # Despliegue de zona maestra en HA
    virt::services::opennebula { "master-zone":
        require => Storage::Ceph["ceph-10"],
        id => '10',
        mode => 'ha',
        zone_id => '0'
    }

    # Despliegue de un frontal en zona esclava
    [...]

    # Despliegue de la federación
	virt::services::opennebula::federation { "nebula-federation":
		require => Virt::Services::Opennebula["slave-leader"],
		master => '10',
		slaves => ['20']
	}

    # HA de la zona esclava y adhesión de nuevos frontales
    virt::services::opennebula::ha { "slave-zone-ha":
        require => Virt::Services::Opennebula::Federation["nebula-federation"],
        oned => $virt::containers::oned_services['20'][0],
        zone => '100',
        vip => $virt::containers::one_vip['20']
    }
    [...]
    # Creación de Cephfs para OPA y backup
    # Corrección de problemas por el entorno simulado
    [...]

    # Servicio de monitorización
    $virt::containers::deployment_units.each |$id| {
        virt::services::opennebula::monitoring { "monitoring-$id":
            require => Virt::Services::Opennebula["slave-followers"],
            zone_id => $id
        }
    }
}
