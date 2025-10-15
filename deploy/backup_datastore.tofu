terraform {
  required_providers {
    opennebula = {
      source = "opentofu/opennebula"
      version = "1.4.1"
    }
  }
}

provider "opennebula" {
    endpoint = "http://192.168.10.1:2633/RPC2"
    alias = "backup-10"
    username = "oneadmin"
    password = "oneadmin"
}

provider "opennebula" {
    endpoint = "http://192.168.20.1:2633/RPC2"
    alias = "backup-20"
    username = "oneadmin"
    password = "oneadmin"
}

#
# Define local variables
#
locals {
   zone1 = {
     nebula = {
        federation_index = 10
        ipaddress = "192.168.10.55"
        password = "oneadmin"
        ssh_keys = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABgQCDJtU18jEl0tQcqZNKmAt54GiGmb2qUK5cb108r5CNdEVBSfpuBULnbYcsmxeJDeIP75qceqOr0c//Z1rPJZy7CpULW+Zi1Ctg/RKKsZYpn/drVPuwj3R3JbuQBh24zPG78jeWZc7PuqDuRTMkSQlxuSeBJqZeisiI2BJv2SYHkb4qgTWy+PsPwsOIVO0zaVgcik+tBEnu5jzkRXNrpWt6uB+UgtoS3SMjSRKU8OtF+aFhUl5xzyOMtqwlAKqUpdTM8PIqW/OtQ8YYgqay58f4IxD86DHTjiXTALvTWBtaV3nxXT3XoOpCwgNxecUNdee5RdrX1ncH5LOsq3YNPtKyN92FkXBPrmI2pvr7VbkIECuvQX0fY0D+6alUpdB9U1S34z/cYcM8SObM8lnmsqDvU0G7M7jJROoeJvuBwCt9MR5BIM+cnAFmrOu4sF8YS/XS80A53RMZtl9cHipclCkLKQQxnI/ieGjeUeN6xRaJUE2wRdkW0sgicMRPuC4MVNM="
     }
     ceph = {
        ceph_user = "backup"
        fs_name = "backup"
        fsid = "8dbb325d-3811-4f2d-8a1b-6443ffb493af"
        cluster_name = "ceph-10"
        monitor = "192.168.10.90"
        key = "AQAfZe5oeGsiNxAAnU8cfD1GvS0cpK4uZuew/A=="
     }
   }
   zone2 = {
     nebula = {
        federation_index = 20
        ipaddress = "192.168.20.55"
        password = "oneadmin"
        ssh_keys = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABgQCDJtU18jEl0tQcqZNKmAt54GiGmb2qUK5cb108r5CNdEVBSfpuBULnbYcsmxeJDeIP75qceqOr0c//Z1rPJZy7CpULW+Zi1Ctg/RKKsZYpn/drVPuwj3R3JbuQBh24zPG78jeWZc7PuqDuRTMkSQlxuSeBJqZeisiI2BJv2SYHkb4qgTWy+PsPwsOIVO0zaVgcik+tBEnu5jzkRXNrpWt6uB+UgtoS3SMjSRKU8OtF+aFhUl5xzyOMtqwlAKqUpdTM8PIqW/OtQ8YYgqay58f4IxD86DHTjiXTALvTWBtaV3nxXT3XoOpCwgNxecUNdee5RdrX1ncH5LOsq3YNPtKyN92FkXBPrmI2pvr7VbkIECuvQX0fY0D+6alUpdB9U1S34z/cYcM8SObM8lnmsqDvU0G7M7jJROoeJvuBwCt9MR5BIM+cnAFmrOu4sF8YS/XS80A53RMZtl9cHipclCkLKQQxnI/ieGjeUeN6xRaJUE2wRdkW0sgicMRPuC4MVNM="
     }
     ceph = {
        ceph_user = "backup"
        fs_name = "backup"
        fsid = "afdc009a-b62a-4095-858d-a19616262820"
        cluster_name = "ceph-20"
        monitor = "192.168.20.90"
        key = "AQBZZ+5oQKTxEBAAMWIyrgsv2wKAHHeR3s2GSw=="
     }
  }
}

#
# Define vnet
#

resource "opennebula_virtual_network" "backup-10" {
  provider = opennebula.backup-10
  name            = "backup-10"
  type            = "802.1Q"
  physical_device = "br_kvm"
  vlan_id         = "10"
  gateway         = "192.168.10.254"
  dns             = "155.210.3.12 155.210.12.9"
  mtu             = 1500
}

resource "opennebula_virtual_network" "backup-20" {
  provider = opennebula.backup-20
  name            = "backup-20"
  type            = "802.1Q"
  physical_device = "br_kvm"
  vlan_id         = "20"
  gateway         = "192.168.10.254"
  dns             = "155.210.3.12 155.210.12.9"
  mtu             = 1500
}


resource "opennebula_virtual_network_address_range" "backup_ar-10" {
  provider = opennebula.backup-10
  virtual_network_id = opennebula_virtual_network.backup-10.id
  ar_type            = "IP4"
  size               = 1
  ip4                = local.zone1.nebula.ipaddress
}

resource "opennebula_virtual_network_address_range" "backup_ar-20" {
  provider = opennebula.backup-20
  virtual_network_id = opennebula_virtual_network.backup-20.id
  ar_type            = "IP4"
  size               = 1
  ip4                = local.zone2.nebula.ipaddress
}

#
# Define image
#
resource "opennebula_image" "backup-10" {
  provider = opennebula.backup-10
  name         = "backup"
  description  = "Debian limpio"
  datastore_id = 101
  persistent   = true
  lock         = "UNLOCK"
  path         = "https://marketplace.opennebula.systems/appliance/f4cc1890-f430-013c-b669-7875a4a4f528/download"
  dev_prefix   = "vd"
  driver       = "qcow2"
  type         = "OS"
}

resource "opennebula_image" "backup-20" {
  provider = opennebula.backup-20
  name         = "backup"
  description  = "Debian limpio"
  datastore_id = 101
  persistent   = true
  lock         = "UNLOCK"
  path         = "https://marketplace.opennebula.systems/appliance/f4cc1890-f430-013c-b669-7875a4a4f528/download"
  dev_prefix   = "vd"
  driver       = "qcow2"
  type         = "OS"
}


#
# Define backup VM
#


resource "opennebula_virtual_machine" "backup-10" {
  provider = opennebula.backup-10

  name        = "backup"
  description = "backup vm"
  cpu         = 1
  vcpu        = 1
  memory      = 4096

  context = {
    NETWORK      = "YES"
    HOSTNAME     = "$NAME"
    USERNAME     = "oneadmin"
    PASSWORD     = local.zone1.nebula.password
    SSH_PUBLIC_KEY = local.zone1.nebula.ssh_keys
    START_SCRIPT = <<-EOT
    #!/bin/bash
    apt update && apt install -y rsync qemu-utils
    [ -d /var/lib/one/datastores ] || mkdir -p /var/lib/one/datastores
    chown -R oneadmin:oneadmin /var/lib/one/datastores
    if [ ! -d /etc/ceph ]; then
        mkdir -p -m 755 /etc/ceph
        mount -t ceph ${local.zone1.ceph.ceph_user}@${local.zone1.ceph.fsid}.${local.zone1.ceph.fs_name}=/ /var/lib/one/datastores -o mon_addr=${local.zone1.ceph.monitor}:6789,secret=${local.zone1.ceph.key}
    fi
    EOT
  }

  graphics {
    type   = "VNC"
    listen = "0.0.0.0"
    keymap = "es"
  }

  os {
    arch = "x86_64"
    boot = "disk0"
  }

  disk {
    image_id = opennebula_image.backup-10.id
    target   = "hda"
    driver   = "qcow2"
  }

  nic {
    model           = "virtio"
    network_id      = opennebula_virtual_network.backup-10.id
  }

}

resource "opennebula_virtual_machine" "backup-20" {
  provider = opennebula.backup-20

  name        = "backup"
  description = "backup vm"
  cpu         = 1
  vcpu        = 1
  memory      = 4096

  context = {
    NETWORK      = "YES"
    HOSTNAME     = "$NAME"
    USERNAME     = "oneadmin"
    PASSWORD     = local.zone2.nebula.password
    SSH_PUBLIC_KEY = local.zone2.nebula.ssh_keys
    START_SCRIPT = <<-EOT
    #!/bin/bash
    apt update && apt install -y rsync qemu-utils
    [ -d /var/lib/one/datastores ] || mkdir -p /var/lib/one/datastores
    if [ ! -d /etc/ceph ]; then
        mkdir -p -m 755 /etc/ceph
        mount -t ceph ${local.zone2.ceph.ceph_user}@${local.zone2.ceph.fsid}.${local.zone2.ceph.fs_name}=/ /var/lib/one/datastores -o mon_addr=${local.zone2.ceph.monitor}:6789,secret=${local.zone2.ceph.key}
    fi
    chown -R oneadmin:oneadmin /var/lib/one/datastores
    EOT
  }

  graphics {
    type   = "VNC"
    listen = "0.0.0.0"
    keymap = "es"
  }

  os {
    arch = "x86_64"
    boot = "disk0"
  }

  disk {
    image_id = opennebula_image.backup-20.id
    target   = "hda"
    driver   = "qcow2"
  }

  nic {
    model           = "virtio"
    network_id      = opennebula_virtual_network.backup-20.id
  }

}

#
# Datastore definition
#

resource "opennebula_datastore" "backup-10" {
 provider = opennebula.backup-10
 name = "backup"

 custom {
  datastore = "restic"
  transfer = "shared"
 }

 tags = {
  restic_password = "opennebula"
  restic_sftp_server = "${local.zone1.nebula.ipaddress}"
  type = "BACKUP_DS"
 }
 type = "IMAGE"
}

resource "opennebula_datastore" "backup-20" {
 provider = opennebula.backup-20
 name = "backup"

 custom {
  datastore = "restic"
  transfer = "shared"
 }

 tags = {
  restic_password = "opennebula"
  restic_sftp_server = local.zone2.nebula.ipaddress
  type = "BACKUP_DS"
  tm_mad = "-"
 }
 type = "IMAGE"
}

