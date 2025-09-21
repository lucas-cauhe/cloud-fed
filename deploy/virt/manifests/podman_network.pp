define virt::podman_network (
	String $id
){ 
	virt::podman_unit { "pod_one_$id.network":
		args => {
			podman_network_entry => {
				'Driver' => 'macvlan',
				'Gateway' => "192.168.$id.254",
				'IPRange' => "192.168.$id.0/25",
				'NetworkName' => "pod_one_$id",
				'Options' => 'parent=br_one',
				'Subnet' => "192.168.$id.0/24",
			},
		}
	}

	virt::podman_unit { "pod_ceph_$id.network":
		args => {
		podman_network_entry => {
				'Driver' => 'macvlan',
				'Gateway' => "192.168.$id.254",
				'IPRange' => "192.168.$id.0/25",
				'NetworkName' => "pod_ceph_$id",
				'Options' => 'parent=br_ceph',
				'Subnet' => "192.168.$id.0/24",
			
			}
		}
	}

	virt::podman_unit { "pod_stor_$id.network":
		args => {
			podman_network_entry => {
				'Driver' => 'macvlan',
				'Gateway' => "192.168.30.254",
				'IPRange' => "192.168.30.0/25",
				'NetworkName' => "pod_stor_$id",
				'Options' => 'parent=br_stor',
				'Subnet' => '192.168.30.0/24',
			},
		}
	}
}
