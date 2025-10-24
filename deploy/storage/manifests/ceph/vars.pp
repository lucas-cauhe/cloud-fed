class storage::ceph::vars {
	$ceph_release = "18.2.7"
	$network = {
		'10' => {
			'osds' => [
				{'hostname' => 'osd-0-10', 'ipaddress' => '192.168.10.80', 'cluster_ipaddress' => '192.168.30.80'},
				{'hostname' => 'osd-1-10', 'ipaddress' => '192.168.10.81', 'cluster_ipaddress' => '192.168.30.81'},
				{'hostname' => 'osd-2-10', 'ipaddress' => '192.168.10.82', 'cluster_ipaddress' => '192.168.30.82'},
				{'hostname' => 'osd-3-10', 'ipaddress' => '192.168.10.83', 'cluster_ipaddress' => '192.168.30.83'},
				{'hostname' => 'osd-4-10', 'ipaddress' => '192.168.10.84', 'cluster_ipaddress' => '192.168.30.84'},
			],
			'mon' => [
				{'hostname' => 'mon-0-10', 'ipaddress' => '192.168.10.90'},
				{'hostname' => 'mon-1-10', 'ipaddress' => '192.168.10.91'},
				{'hostname' => 'mon-2-10', 'ipaddress' => '192.168.10.92'}
			],
			'mgr' => [
				# active
				{'hostname' => 'mgr-0-10', 'ipaddress' => '192.168.10.93'},
				# standby
				{'hostname' => 'mgr-1-10', 'ipaddress' => '192.168.10.94'}
			],
			'mds' => [
				# active
				{'hostname' => 'mds-0-10', 'ipaddress' => '192.168.10.100'},
				# standby
				{'hostname' => 'mds-1-10', 'ipaddress' => '192.168.10.101'},
				{'hostname' => 'mds-2-10', 'ipaddress' => '192.168.10.102'},
				{'hostname' => 'mds-3-10', 'ipaddress' => '192.168.10.103'},
			],
			'network_gateway' => '10.88.0.144',
			'ceph_cluster_net' => '192.168.30.0/24',
			'ceph_public_net' => '192.168.10.0/24'
		},
		'20' => {
			'osds' => [
				{'hostname' => 'osd-0-20', 'ipaddress' => '192.168.20.80', 'cluster_ipaddress' => '192.168.30.80'},
				{'hostname' => 'osd-1-20', 'ipaddress' => '192.168.20.81', 'cluster_ipaddress' => '192.168.30.81'},
				{'hostname' => 'osd-2-20', 'ipaddress' => '192.168.20.82', 'cluster_ipaddress' => '192.168.30.82'},
				{'hostname' => 'osd-3-20', 'ipaddress' => '192.168.20.83', 'cluster_ipaddress' => '192.168.30.83'},
				{'hostname' => 'osd-4-20', 'ipaddress' => '192.168.20.84', 'cluster_ipaddress' => '192.168.30.84'},
			],
			'mon' => [
				{'hostname' => 'mon-0-20', 'ipaddress' => '192.168.20.90'},
				{'hostname' => 'mon-1-20', 'ipaddress' => '192.168.20.91'},
				{'hostname' => 'mon-2-20', 'ipaddress' => '192.168.20.92'}
			],
			'mgr' => [
				# active
				{'hostname' => 'mgr-0-20', 'ipaddress' => '192.168.20.93'},
				# standby
				{'hostname' => 'mgr-1-20', 'ipaddress' => '192.168.20.94'}
			],
			'mds' => [
				# active
				{'hostname' => 'mds-0-20', 'ipaddress' => '192.168.20.100'},
				# standby
				{'hostname' => 'mds-1-20', 'ipaddress' => '192.168.20.101'},
				{'hostname' => 'mds-2-20', 'ipaddress' => '192.168.20.102'},
				{'hostname' => 'mds-3-20', 'ipaddress' => '192.168.20.103'},
			],
			'network_gateway' => '10.88.0.144',
			'ceph_cluster_net' => '192.168.30.0/24',
			'ceph_public_net' => '192.168.20.0/24'
		}
	}

	$fsid = {
		 '10' => storage::uuid(),
		 '20' => storage::uuid()
	}
	$cluster_name = {
		'10' => 'ceph-10',
		'20' => 'ceph-20'
	}
}
