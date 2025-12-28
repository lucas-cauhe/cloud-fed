include virt::containers
#
# Definición de redes locales
#
$bridge_ifaces = ['br_vm0', 'br_vm1']

$bridge_ifaces.each |$iface| {
    systemd::manage_unit { "${iface}.netdev":
        path => '/etc/systemd/network',
        netdev_entry => {
                'Name' => "${iface}",
                'Kind' => 'bridge',
        },

        bridge_entry => {
                'STP' => 'yes',
                'VLANFiltering' => 'yes',
        },
        service_restart => true
    }

    systemd::manage_unit { "${iface}.network":
        path => '/etc/systemd/network',
        match_entry => {
                'Name' => $iface,
        }
    }
}
exec { 'restart-network':
    require => [Systemd::Manage_unit["br_vm0.network"], Systemd::Manage_unit["br_vm1.network"]],
    path => '/usr/bin',
    command => "systemctl daemon-reload && systemctl restart systemd-networkd"
}

#
# Definición de redes podman
#
file { "/etc/containers/systemd":
    ensure => 'directory'
}
virt::podman_unit { "vm0.network":
    require => [File["/etc/containers/systemd"], Exec['restart-network']],
    args => {
        podman_network_entry => {
            'Driver' => 'macvlan',
            'Gateway' => "192.168.10.254",
            'IPRange' => "192.168.10.0/25",
            'NetworkName' => "vm0",
            'Options' => 'parent=br_vm0',
            'Subnet' => "192.168.10.0/24",
        },
    }
}

virt::podman_unit { "vm1.network":
    require => [File["/etc/containers/systemd"], Exec['restart-network']],
    args => {
        podman_network_entry => {
            'Driver' => 'macvlan',
            'Gateway' => "192.168.20.254",
            'IPRange' => "192.168.20.0/25",
            'NetworkName' => "vm1",
            'Options' => 'parent=br_vm1',
            'Subnet' => "192.168.20.0/24",
        },
    }
}

#
# Creación del gateway
#
class {'virt::services::gateway':
    require => [Virt::Podman_unit["vm0.network"],Virt::Podman_unit["vm1.network"]],
}

