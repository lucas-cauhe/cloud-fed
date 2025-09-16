
include 'libvirt'
libvirt::domain { 'one-sched':
	type => 'lxc',
	devices_profile => 'default',
	dom_profile => 'default',
	interfaces => [{'source' => {'network' => 'virt_one'}}],
	autostart => true
}
