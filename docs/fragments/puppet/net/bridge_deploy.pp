#######################################
### 	    BRIDGE DEFINITION       ###
#######################################
class net::bridge_deploy {
        net::bridge { 'br_pub_one_10':
                br_name => 'br_pub_one_10',
                devices => [],
                service_options => {
                        ensure => 'present',
                        onboot => true,
                        method => 'manual'
                }
        }


        net::bridge {'br_pub_ceph_10':
                br_name => 'br_pub_ceph_10',
                devices => [],
                service_options => {
                        ensure => 'present',
                        onboot => true,
                        method => 'manual'
                }
        }

        net::bridge {'br_pub_kvm_10':
                br_name => 'br_pub_kvm_10',
                devices => [],
                service_options => {
                        ensure => 'present',
                        onboot => true,
                        method => 'manual'
                }
        }
        net::bridge {'br_priv_ceph_11':
                br_name => 'br_priv_ceph_11',
                devices => [],
                service_options => {
                        ensure => 'present',
                        onboot => true,
                        method => 'manual'
                }
        }
        net::bridge {'br_pub_one_20':
                br_name => 'br_pub_one_20',
                devices => [],
                service_options => {
                        ensure => 'present',
                        onboot => true,
                        method => 'manual'
                }
        }
        net::bridge {'br_pub_ceph_20':
                br_name => 'br_pub_ceph_20',
                devices => [],
                service_options => {
                        ensure => 'present',
                        onboot => true,
                        method => 'manual'
                }
        }
        net::bridge {'br_pub_kvm_20':
                br_name => 'br_pub_kvm_20',
                devices => [],
                service_options => {
                        ensure => 'present',
                        onboot => true,
                        method => 'manual'
                }
        }
        net::bridge {'br_priv_ceph_21':
                br_name => 'br_priv_ceph_21',
                devices => [],
                service_options => {
                        ensure => 'present',
                        onboot => true,
                        method => 'manual'
                }
        }
}

