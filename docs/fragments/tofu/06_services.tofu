#
# OPA engine VM
#
resource "opennebula_virtual_machine" "opa-10" {
  provider = opennebula.policies-10

  name        = "one-10-policies_10-opa"
  description = "opa engine vm"
  cpu         = 1
  vcpu        = 1
  memory      = 4096
  group       = "policies"
  permissions = "740" # use and manage by zone user and only use by policies group

  context = {
    NETWORK      = "YES"
    HOSTNAME     = "$NAME"
    USERNAME     = "oneadmin"
    PASSWORD     = local.zone1.nebula.password
    SSH_PUBLIC_KEY = local.zone1.nebula.ssh_keys
    START_SCRIPT = <<-EOT
    #!/bin/bash
    apt update && apt install -y podman
    [ -d /var/lib/policies ] || mkdir -p /var/lib/policies
    chown -R oneadmin:oneadmin /var/lib/policies
    if [ ! -d /etc/ceph ]; then
        mkdir -p -m 755 /etc/ceph
        mount -t ceph policies@${local.zone1.ceph.fsid}.${local.zone1.ceph.users.policies.fs_name}=/ /var/lib/policies -o mon_addr=${local.zone1.ceph.monitor}:6789,secret=${local.zone1.ceph.users.policies.key}
    fi
    sudo podman run -v /var/lib/policies:/policies -p 2345:2345 docker.io/openpolicyagent/opa     run --server --log-level debug --addr=0.0.0.0:2345 /policies
    EOT
  }

  # requerido para ejecutar contenedores
  raw {
    type = "kvm"
    data = "<cpu mode='host-passthrough'/>"
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

resource "opennebula_virtual_machine" "opa-20" {
  provider = opennebula.policies-20

  name        = "one-20-policies_20-opa"
  description = "opa engine vm"
  cpu         = 1
  vcpu        = 1
  memory      = 4096
  group       = "policies"
  permissions = "740" # use and manage by zone user and only use by policies group

  context = {
    NETWORK      = "YES"
    HOSTNAME     = "$NAME"
    USERNAME     = "oneadmin"
    PASSWORD     = local.zone1.nebula.password
    SSH_PUBLIC_KEY = local.zone1.nebula.ssh_keys
    START_SCRIPT = <<-EOT
    #!/bin/bash
    apt update && apt install -y podman
    [ -d /var/lib/policies ] || mkdir -p /var/lib/policies
    chown -R oneadmin:oneadmin /var/lib/policies
    if [ ! -d /etc/ceph ]; then
        mkdir -p -m 755 /etc/ceph
        mount -t ceph policies@${local.zone2.ceph.fsid}.${local.zone2.ceph.users.policies.fs_name}=/ /var/lib/policies -o mon_addr=${local.zone2.ceph.monitor}:6789,secret=${local.zone2.ceph.users.policies.key}
    fi
    sudo podman run -v /var/lib/policies:/policies -p 2345:2345 docker.io/openpolicyagent/opa     run --server --log-level debug --addr=0.0.0.0:2345 /policies
    EOT
  }

  # requerido para ejecutar contenedores
  raw {
    type = "kvm"
    data = "<cpu mode='host-passthrough'/>"
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
