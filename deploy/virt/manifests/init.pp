class virt {
	include virt::containers
	file { "/etc/containers/systemd":
		ensure => 'directory',
	} 
	$virt::containers::deployment_units.each |$id| {
		virt::podman_network { "network-$id":
			require => File["/etc/containers/systemd"],
			id => $id
		}
	}
	class {'virt::services::gateway':
		require => $virt::containers::deployment_units.map |$du| { Virt::Podman_network["network-$du"] },
	}
	$virt::containers::deployment_units.each |$id| {
		storage::ceph {"ceph-$id":
			require => Class["virt::services::gateway"], 
			id => $id
		}->
		virt::services { "services-$id":
			id => $id
		}
	}
	virt::services::opennebula::federation { "nebula-federation":
		require => $virt::containers::deployment_units.map |$du| { Virt::Services["services-$du"] }, 
		master => '10',
		slaves => ['20']
	}
}
