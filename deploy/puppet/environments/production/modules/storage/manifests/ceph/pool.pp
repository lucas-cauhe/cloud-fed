define storage::ceph::pool (
	Enum['replicated', 'erasure'] $type = 'replicated',
	Enum['on', 'off', 'warn'] $pg_autoscale = 'off',
	Optional[String] $cluster_name = undef,
	Optional[String] $pg_num = undef,
    Boolean $rbd = true,
    Optional[Hash] $ecpool_opts = undef
) {

	$cluster_name_ = common::unwrap_or($cluster_name, $storage::ceph::vars::cluster_name["10"])
    $pg_num_ = common::unwrap_or($pg_num, "")

	notice("Defined ceph pool $name")

    #
    # Set ecpool options if needed
    #
    if $type == 'erasure' {
        $profile_values = join($ecpool_opts.map  |$k, $v| { "$k=$v" }, " ")
        exec { "erasure-profile-$cluster_name-$name":
            command => "/usr/sbin/cephadm shell -m /etc/$cluster_name_:/etc/ceph -- ceph osd erasure-code-profile set ecprofile $profile_values"
        }->
        exec { "create-$cluster_name-$name-pool":
            command => "/usr/sbin/cephadm shell -m /etc/$cluster_name_:/etc/ceph -- ceph osd pool create $name $pg_num_ $type ecprofile --autoscale-mode=$pg_autoscale"
        }
    } else {
        #
        # Create the pool
        #
        exec { "create-$cluster_name-$name-pool":
            command => "/usr/sbin/cephadm shell -m /etc/$cluster_name_:/etc/ceph -- ceph osd pool create $name $pg_num_ $type --autoscale-mode=$pg_autoscale"
        }
    }


    if $rbd {
        #
        # Enable the pool
        #
        exec { "/usr/sbin/cephadm shell -m /etc/$cluster_name_:/etc/ceph -- ceph osd pool application enable $name rbd":
            require => Exec["create-$cluster_name-$name-pool"]
        }->

        #
        # Init the pool
        #
        exec { "/usr/sbin/cephadm shell -m /etc/$cluster_name_:/etc/ceph -- rbd pool init -p $name":
        }
    }

}
