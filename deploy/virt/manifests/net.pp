
libvirt::network { 'virt_one':
	forward_mode => 'bridge',
	bridge       => 'br_one',
	
}

libvirt::network { 'virt_ceph':
	forward_mode => 'bridge',
	bridge       => 'br_ceph',
	
}
libvirt::network { 'virt_kvm':
	forward_mode => 'bridge',
	bridge       => 'br_kvm',
	
}
libvirt::network { 'virt_stor':
	forward_mode => 'bridge',
	bridge       => 'br_stor',
	
}
