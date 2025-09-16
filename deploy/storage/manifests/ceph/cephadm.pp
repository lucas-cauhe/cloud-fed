define storage::ceph::cephadm (
	String $config_path = "/etc/ceph",
	String $fsid = "",
	Array[Hash] $monitors = []
) {
	
	#
	# Requirements 
	#
	$requirements = [{ binary => 'python3', version => '>3.8'}, 'podman']
	$requirements.each |$req| {
		$real_req = $req =~ Hash ? { false => $req, default => $req[binary] } 
		unless $facts["installed_binaries"][$real_req] {
			err("${real_req} not installed")
		}
		common::compare_versions($facts["installed_binaries"][$real_req]["version"], $req =~ Hash ? { true => $req[version], default => "any" })
	}
	$required_services = ['chrony'] # lvm2 is already installed so not needed to check
	$required_services.each |$service| {
		ensure_resource('package', $service, {ensure => present})
	}

	#
	# Install cephadm
	#
	ensure_resource('package', "cephadm", {
		ensure	=> 'installed',
		provider => 'apt'
	})

	file { $config_path:
		ensure => 'directory',
		recurse => true
	}

	#
	# Configure cephadm
	#
	file { "$config_path/ceph.conf":
		ensure => 'present',
		require => [Package["cephadm"], File["$config_path"]],
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
	}

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
		require => [Package["cephadm"], File[$config_path]],
	}
}
