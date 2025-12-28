define virt::services::opennebula::kvm_node {
	#
	# Add opennebula-node-kvm package
	#
    package { ["gnupg", "wget", "apt-transport-https"]:
        ensure => 'installed'
    } ->
    exec { "/usr/bin/wget -q -O- https://downloads.opennebula.io/repo/repo2.key | /usr/bin/gpg --dearmor --yes --output /etc/apt/keyrings/opennebula.gpg":
    }->
    file { '/etc/apt/sources.list.d/opennebula.list':
        ensure => 'present',
        content => "deb [signed-by=/etc/apt/keyrings/opennebula.gpg] https://downloads.opennebula.io/repo/6.10/Debian/12 stable opennebula"
    }->
    exec { "/usr/bin/apt-get update":
    }->
	package { "opennebula-node-kvm":
		ensure => 'installed'
	}->
	file { "/var/lib/one":
		ensure => 'directory',
		owner => 'oneadmin',
		group => 'oneadmin'
	}->
	file { "/var/lib/one/.ssh":
		ensure => 'directory',
		recurse => true,
		purge => true,
		force => true
	}
	exec { "/usr/bin/ssh-keygen -t rsa -f /var/lib/one/.ssh/id_rsa -b 4096 -N '' -q":
		refreshonly => true,
		subscribe => File["/var/lib/one/.ssh"]
	}->
	exec { "/usr/bin/chown oneadmin:oneadmin /var/lib/one/.ssh":
	}->
	exec {"/usr/bin/systemctl restart libvirtd":
	}

	#
	# Set appropriate apparmor profiles
	#
	file_line { "one node apparmor profile":
		path => '/etc/apparmor.d/abstractions/libvirt-qemu',
		line => '/var/lib/one/datastores/** rwk,',
		ensure => 'present'
	}

	#
	# Networking is bridged and over the kvm bridge already defined
	#
}
