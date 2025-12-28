# Author | Lucas Cauhé Viñao
# Contact | lcauhe@gmail.com
# Description | Storage definition
# Docs -> https://forge.puppet.com/modules/puppetlabs/lvm/readme

class storage::lvm_stor (
	Array[String] $devices = ['/dev/sda'],
	Array[Hash] $lvs = {},
	) {
	$lvm2 = $facts['os']['name'] ? {
		default => lvm2
	}
	$vg_name = 'main'
	package { "lvm":
		ensure	=> installed,
		name    => $lvm2,
	}
	$devices.each |$device| {
		physical_volume { $device:
		  ensure => present,
		  require => Package['lvm'],
		}
	}

	volume_group { $vg_name:
	  ensure           => present,
	  physical_volumes => $devices,
	}

	$lvs.each |$lv| {
		lvm::logical_volume { $lv[name]:
		  ensure       => present,
		  volume_group => $vg_name,
		  size         => $lv[size],
		  yes_flag     => true, # wipe fs signatures
		  fs_type      => $lv[fs_type],
		  createfs     => $lv[fs_type] ? {
		  	'raw' => false,
			default => true
		  },
		  mountpath      => $lv[mount],
		}
	}
}
