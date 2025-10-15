federation_attrs = [
        {
            name = "backup-10"
            federation_index = 10
            ipaddress = "192.168.10.55"
            password = "oneadmin"
        },
        {
            name = "backup-20"
            federation_index = 20
            ipaddress = "192.168.20.55"
            password = "oneadmin"
        }

]

cephfs = [
    {
        ceph_user = "backup"
        fs_name = "backup"
        fsid = ""
        cluster_name = "ceph-10"
        key = ""
    },
    {
        ceph_user = "backup"
        fs_name = "backup"
        fsid = ""
        cluster_name = "ceph-20"
        key = ""
    }
]
