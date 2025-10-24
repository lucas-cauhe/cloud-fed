#
# Oneadmin providers
#
provider "opennebula" {
    endpoint = "http://192.168.10.1:2633/RPC2"
    alias = "one-10"
    username = "oneadmin"
    password = "oneadmin"
}

provider "opennebula" {
    endpoint = "http://192.168.20.1:2633/RPC2"
    alias = "one-20"
    username = "oneadmin"
    password = "oneadmin"
}


#
# Define local variables
#
locals {
   services = ["opa", "backup"]
   zone1 = {
     policies_password = "policies"
     nebula = {
        federation_index = 10
        ipaddress = "192.168.10.55"
        password = "oneadmin"
        ssh_keys = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABgQCDJtU18jEl0tQcqZNKmAt54GiGmb2qUK5cb108r5CNdEVBSfpuBULnbYcsmxeJDeIP75qceqOr0c//Z1rPJZy7CpULW+Zi1Ctg/RKKsZYpn/drVPuwj3R3JbuQBh24zPG78jeWZc7PuqDuRTMkSQlxuSeBJqZeisiI2BJv2SYHkb4qgTWy+PsPwsOIVO0zaVgcik+tBEnu5jzkRXNrpWt6uB+UgtoS3SMjSRKU8OtF+aFhUl5xzyOMtqwlAKqUpdTM8PIqW/OtQ8YYgqay58f4IxD86DHTjiXTALvTWBtaV3nxXT3XoOpCwgNxecUNdee5RdrX1ncH5LOsq3YNPtKyN92FkXBPrmI2pvr7VbkIECuvQX0fY0D+6alUpdB9U1S34z/cYcM8SObM8lnmsqDvU0G7M7jJROoeJvuBwCt9MR5BIM+cnAFmrOu4sF8YS/XS80A53RMZtl9cHipclCkLKQQxnI/ieGjeUeN6xRaJUE2wRdkW0sgicMRPuC4MVNM="
     }
     ceph = {
        fsid = "4d006b2c-a99d-4410-9b01-152944055b7b"
        cluster_name = "ceph-10"
        monitor = "192.168.10.90"
        users = {
            backup = {
                fs_name = "backup-10"
                key = "AQDXJPpoOhWpJhAAuFUHLyKQuf6UTXSbHd1Tgw=="
            }
            policies = {
                fs_name = "policies-10"
                key = "AQD3JPpoXpSNJRAA/r32NxgIFBjlfSrmWdltIw=="
            }
        }
     }
   }
   zone2 = {
     policies_password = "policies"
     nebula = {
        federation_index = 20
        ipaddress = "192.168.20.55"
        password = "oneadmin"
        ssh_keys = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABgQCDJtU18jEl0tQcqZNKmAt54GiGmb2qUK5cb108r5CNdEVBSfpuBULnbYcsmxeJDeIP75qceqOr0c//Z1rPJZy7CpULW+Zi1Ctg/RKKsZYpn/drVPuwj3R3JbuQBh24zPG78jeWZc7PuqDuRTMkSQlxuSeBJqZeisiI2BJv2SYHkb4qgTWy+PsPwsOIVO0zaVgcik+tBEnu5jzkRXNrpWt6uB+UgtoS3SMjSRKU8OtF+aFhUl5xzyOMtqwlAKqUpdTM8PIqW/OtQ8YYgqay58f4IxD86DHTjiXTALvTWBtaV3nxXT3XoOpCwgNxecUNdee5RdrX1ncH5LOsq3YNPtKyN92FkXBPrmI2pvr7VbkIECuvQX0fY0D+6alUpdB9U1S34z/cYcM8SObM8lnmsqDvU0G7M7jJROoeJvuBwCt9MR5BIM+cnAFmrOu4sF8YS/XS80A53RMZtl9cHipclCkLKQQxnI/ieGjeUeN6xRaJUE2wRdkW0sgicMRPuC4MVNM="
     }
     ceph = {
        fsid = "420e41dd-a068-43fe-9cbc-13b0e9c66bf0"
        cluster_name = "ceph-20"
        monitor = "192.168.20.90"
        users = {
            backup = {
                fs_name = "backup-20"
                key = "AQAYJfpoDjTFIxAAFoRCQAjSt0IdwTNSn1Q5Lg=="
            }
            policies = {
                fs_name = "policies-20"
                key = "AQA5Jfpodod1GBAADh2L9bjpXR4dHZ3m+uQQIg=="
            }
        }
     }
  }
}

#
# Services federation group
#
resource "opennebula_group" "services" {
    provider = opennebula.one-10
    name = "services"
}

resource "opennebula_acl" "services_acl" {
    provider = opennebula.one-10
    user = "@${opennebula_group.services.id}"
    resource = "VM+NET+IMAGE+TEMPLATE/*"
    rights = "CREATE+USE+MANAGE+ADMIN"
}

#
# Policies federation group
#
resource "opennebula_group" "policies" {
    provider = opennebula.one-10
    name = "policies"
}

resource "opennebula_acl" "policies_acl" {
    provider = opennebula.one-10
    user = "@${opennebula_group.policies.id}"
    resource = "VM+NET+IMAGE+TEMPLATE/*"
    rights = "CREATE+USE+MANAGE+ADMIN"
}
#
# Policies zone user
#
resource "opennebula_user" "policies_10" {
    provider = opennebula.one-10
    name = "policies_10"
    password = local.zone1.policies_password
    auth_driver = "core"
    primary_group = opennebula_group.policies.id
    groups = [opennebula_group.services.id]
}

resource "opennebula_user" "policies_20" {
    provider = opennebula.one-20
    name = "policies_20"
    password = local.zone2.policies_password
    auth_driver = "core"
    primary_group = opennebula_group.policies.id
    groups = [opennebula_group.services.id]
}


#
# Policies user provider
#
provider "opennebula" {
    endpoint = "http://192.168.10.1:2633/RPC2"
    alias = "policies-10"
    username = "policies_10"
    password = local.zone1.policies_password
}

provider "opennebula" {
    endpoint = "http://192.168.20.1:2633/RPC2"
    alias = "policies-20"
    username = "policies_20"
    password = local.zone2.policies_password
}
