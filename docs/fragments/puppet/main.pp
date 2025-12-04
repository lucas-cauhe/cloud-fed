# Despliegue del almacenamiento local
class { 'storage::lvm_stor':
	devices => ['/dev/sda'],
	lvs     => [
		{ name => 'osd-0-10', size => '20G', mount => '/dev/none', fs_type => 'raw' },
		{ name => 'osd-1-10', size => '20G', mount => '/dev/none', fs_type => 'raw' },
		{ name => 'osd-2-10', size => '20G', mount => '/dev/none', fs_type => 'raw' },
		{ name => 'osd-3-10', size => '20G', mount => '/dev/none', fs_type => 'raw' },
		{ name => 'osd-4-10', size => '20G', mount => '/dev/none', fs_type => 'raw' },
		{ name => 'osd-0-20', size => '20G', mount => '/dev/none', fs_type => 'raw' },
		{ name => 'osd-1-20', size => '20G', mount => '/dev/none', fs_type => 'raw' },
		{ name => 'osd-2-20', size => '20G', mount => '/dev/none', fs_type => 'raw' },
		{ name => 'osd-3-20', size => '20G', mount => '/dev/none', fs_type => 'raw' },
		{ name => 'osd-4-20', size => '20G', mount => '/dev/none', fs_type => 'raw' },
	],
} ~>
# Despliegue de la red local
class { 'net::ifaces':
} ~>
# Despliegue de los servicios virtualizados
class { 'virt': }
