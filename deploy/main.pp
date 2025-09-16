class { 'storage::lvm_stor':
	devices => ['/dev/sdb'],
	lvs     => [
		#{ name => 'one_db', size => '20G', mount => '/opt/one_db', fs_type => 'xfs' },
		{ name => 'osd-0-10', size => '20G', mount => '/dev/none', fs_type => 'raw' },
		{ name => 'osd-1-10', size => '20G', mount => '/dev/none', fs_type => 'raw' },
		{ name => 'osd-2-10', size => '20G', mount => '/dev/none', fs_type => 'raw' },
		{ name => 'osd-0-20', size => '20G', mount => '/dev/none', fs_type => 'raw' },
		{ name => 'osd-1-20', size => '20G', mount => '/dev/none', fs_type => 'raw' },
		{ name => 'osd-2-20', size => '20G', mount => '/dev/none', fs_type => 'raw' },
	],
} ~>
class { 'net::ifaces': 
} ~>
class { 'virt': }
