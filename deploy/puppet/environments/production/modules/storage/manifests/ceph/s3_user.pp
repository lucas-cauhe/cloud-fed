define storage::ceph::s3_user (
    String $display_name = "User-$name",
    String $cluster_name = "ceph-10"
) {
    notice("Creating Ceph S3 user: $name")
    exec { "/usr/sbin/cephadm shell -m /etc/$cluster_name:/etc/ceph -- radosgw-admin user create --uid='$name' --display-name='$display_name'":
        refreshonly => true
    }
}
