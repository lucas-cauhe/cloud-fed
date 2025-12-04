# storage/manifests/ceph/user.pp
define storage::ceph::user (
	String $type = 'client',
	Optional[String] $cluster_name = undef,
	Optional[String] $caps = undef,
    Optional[String] $output = undef
) {
    #
    # Variables locales
    #
	$cluster_name_ = common::unwrap_or($cluster_name, $storage::ceph::vars::cluster_name["10"])
    if $output {
        $redirection = "> /etc/$cluster_name_/$output"
    } else {
        $redirection = ""
    }
	#
	# Create user if doesnt exists
	#
	exec { "/usr/sbin/cephadm shell -m /etc/$cluster_name_:/etc/ceph -- ceph auth get-or-create $type.$name $caps $redirection":
	}
}
