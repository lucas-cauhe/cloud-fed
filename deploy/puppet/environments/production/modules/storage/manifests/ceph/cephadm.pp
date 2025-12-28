define storage::ceph::cephadm (
	String $config_path = "/etc/ceph",
	String $fsid = "",
	Array[Hash] $monitors = []
) {

	#
	# Install cephadm
	#
    user { 'cephadm':
      ensure     => present,
      managehome => true,
      system     => true,
      shell      => '/bin/bash',
    }->

    file { '/home/cephadm':
      ensure  => directory,
      owner   => 'cephadm',
      mode    => '0755',
      require => User['cephadm'],
    }->

    package { ['cephadm', 'python3-yaml', 'python3-jinja2']:
      ensure  => installed,
      provider => 'apt',
    }->

	file { $config_path:
		ensure => 'directory',
		recurse => true
	}->

	#
	# Configure cephadm
	#
	file { "$config_path/ceph.conf":
		ensure => 'present',
		content => epp('storage/ceph_conf', {
			'config' => {
				'global' => {
					'fsid' => $fsid,
					'mon_initial_members' => $monitors.map |$m| { $m[hostname] },
					'mon_host' => $monitors.map |$m| { $m[ipaddress] },
					'container_image' => 'quay.io/ceph/ceph:v18'
				},
				'mon' => {
					'auth_allow_insecure_global_id_reclaim' => false
				}
			}
		})
	}->

	#
	# Generate admin keyring
	#
	exec { "/usr/sbin/cephadm shell -m $config_path:$config_path -- ceph-authtool \
	       -C -g $config_path/ceph.client.admin.keyring \
	       -n client.admin \
	       --cap mon 'allow *' \
	       --cap osd 'allow *' \
	       --cap mds 'allow *' \
	       --cap mgr 'allow *'":
	}
}
