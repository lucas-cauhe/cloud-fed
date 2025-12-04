# storage/manifests/ceph/cephfs.pp
define storage::ceph::cephfs(
	String $id,
	Optional[String] $cluster_name = undef
) {
    #
    # Creación de MDS especificados en la entrada
    #
	$storage::ceph::vars::network[$id][mds].each |$mds| {
		storage::ceph::mds { $mds[hostname]:
			cluster_name => $cluster_name,
			mon => $storage::ceph::vars::network[$id][mon][0],
			ipaddress => $mds[ipaddress],
			id => $id
		}
	}
}
