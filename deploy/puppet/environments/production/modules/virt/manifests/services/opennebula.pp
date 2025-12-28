define virt::services::opennebula(
	String $id,
    Enum['ha', 'slave_leader', 'slave_followers'] $mode = 'ha',
    String $zone_id,
    Optional[Hash] $leader = undef,
    Optional[String] $master = undef
){
	ensure_resource('virt::services::opennebula::kvm_node', "kvm_node", {})

    # Deploy all ha nodes
    if $mode == 'ha' {
        lookup('opennebula')[services].each |$oned| {
            virt::services::opennebula::db { "one-db-${oned[hostname]}-$id":
                fed_id => $id,
                server_name => $oned[hostname]
            }->
            virt::services::opennebula::oned { "${oned[hostname]}":
                require => Virt::Services::Opennebula::Kvm_node["kvm_node"],
                leader => lookup('opennebula')[services][0],
                oned => $oned,
                zone_id => $zone_id,
                fed_id => $id
            }
        }
    }
    # Deploy single service in ha
    elsif $mode == 'slave_leader' {
        $oned = lookup('opennebula')[services][0]
        virt::services::opennebula::db { "one-db-${oned[hostname]}-$id":
            fed_id => $id,
            server_name => $oned[hostname]
        }->
        virt::services::opennebula::oned { "${oned[hostname]}":
            require => Virt::Services::Opennebula::Kvm_node["kvm_node"],
            leader => $oned,
            oned => $oned,
            zone_id => $zone_id,
            fed_id => $id,
            ha => false
        }
    }
    # Deploy nodes to attach to HA cluster
    else {
        lookup('opennebula')[services].each |$oned| {
            if $oned[role] == 'follower' {
                virt::services::opennebula::db { "one-db-${oned[hostname]}-$id":
                    fed_id => $id,
                    server_name => $oned[hostname]
                }->
                virt::services::opennebula::oned { "${oned[hostname]}":
                    require => Virt::Services::Opennebula::Kvm_node["kvm_node"],
                    leader => $leader,
                    oned => $oned,
                    fed_id => $id,
                    zone_id => $zone_id,
                    master_ip => lookup('opennebula')[master_vip]
                }
            }
        }

    }

    #
    # Configure Ceph datastore when all nodes have attached to the cluster
    #
    if $mode == 'ha' or $mode == 'slave_followers' {
        virt::services::opennebula::ceph { "nebula-ceph-$id":
            require => Virt::Services::Opennebula::Oned["oned_2_$id"],
            frontend_nodes => lookup('opennebula')[services].map |$oned| {
                $oned[hostname]
            },
            fed_id => $id
        }
    }
}
