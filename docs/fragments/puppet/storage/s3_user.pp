# storage/manifests/ceph/s3_user.pp
define storage::ceph::s3_user (
    String $display_name = "User-$name"
) {
    notice("Creating Ceph S3 user: $name")

    # Creación de usuario de s3
    exec { "/usr/sbin/cephadm shell -m /etc/ceph-10:/etc/ceph -- radosgw-admin user create --uid='$name' --display-name='$display_name'":
        refreshonly => true
    }
}
