define virt::services::opennebula(
	String $id
){
	ensure_resource('virt::services::opennebula::db', "one_db", {})
	ensure_resource('virt::services::opennebula::kvm_node', "kvm_node", {})
	$virt::containers::oned_services[$id].each |$oned| {
		virt::services::opennebula::oned { "${oned[hostname]}":
			require => [Virt::Services::Opennebula::Kvm_node["kvm_node"], Virt::Services::Opennebula::Db["one_db"]],
			leader => $virt::containers::oned_services[$id][0],
			oned => $oned,
			fed_id => $id
		}
	}
	virt::services::opennebula::ceph { "nebula-ceph-$id":
		require => $virt::containers::oned_services[$id].map |$oned| { Virt::Services::Opennebula::Oned[$oned[hostname]] }, 
		frontend_nodes => $virt::containers::oned_services[$id].map |$oned| { $oned[hostname] },
		fed_id => $id
	}
}
