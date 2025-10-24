#
# Define backup VM
#

resource "opennebula_virtual_machine" "backup-10" {
  provider = opennebula.one-10

  name        = "one-10-backup-backup"
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
        mount -t ceph backup@${local.zone1.ceph.fsid}.${local.zone1.ceph.users.backup.fs_name}=/ /var/lib/one/datastores -o mon_addr=${local.zone1.ceph.monitor}:6789,secret=${local.zone1.ceph.users.backup.key}
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
    image_id = opennebula_image.services-10.id
    target   = "hda"
    driver   = "qcow2"
  }

  nic {
    model           = "virtio"
    network_id      = opennebula_virtual_network.services-10.id
  }

}

resource "opennebula_virtual_machine" "backup-20" {
  provider = opennebula.one-20

  name        = "one-20-backup-backup"
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
        mount -t ceph backup@${local.zone2.ceph.fsid}.${local.zone2.ceph.users.backup.fs_name}=/ /var/lib/one/datastores -o mon_addr=${local.zone2.ceph.monitor}:6789,secret=${local.zone2.ceph.users.backup.key}
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
    image_id = opennebula_image.services-20.id
    target   = "hda"
    driver   = "qcow2"
  }

  nic {
    model           = "virtio"
    network_id      = opennebula_virtual_network.services-20.id
  }

}
