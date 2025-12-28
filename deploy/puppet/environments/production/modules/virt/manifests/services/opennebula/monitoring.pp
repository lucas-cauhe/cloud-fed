define virt::services::opennebula::monitoring (
    String $zone_id = "10"
) {

    #
    # KVM Node installation
    #
    ensure_resource('Package', "opennebula-prometheus-kvm", {
        ensure => "installed"
    })

    ensure_resource('Exec', "/usr/bin/systemctl enable --now opennebula-libvirt-exporter.service", {
       require => Package["opennebula-prometheus-kvm"],
    })

    #
    # Frontal Node installation
    #
    lookup('opennebula')[services].each |$oned| {
        exec { "/usr/bin/podman exec ${oned[hostname]} dnf install -y opennebula-prometheus opennebula-prometheus-kvm":
        }->
        exec { "/usr/bin/podman exec ${oned[hostname]} /usr/bin/ruby /usr/lib/one/opennebula_exporter/opennebula_exporter.rb &":
        }
    }

    if $zone_id == '10' {
        #
        # Generate config
        #
        $fst_oned = lookup('opennebula')[services][0][hostname]
        $prometheus_folder = "/etc/one-$zone_id/prometheus"
        file { ["/etc/one-$zone_id", $prometheus_folder]:
            ensure => 'directory'
        }->
        exec { "/usr/bin/podman exec $fst_oned /usr/share/one/prometheus/patch_datasources.rb":
        }->
        exec { "Copy-prometheus-config-$zone_id":
            command => "/usr/bin/podman cp $fst_oned:/etc/one/prometheus/prometheus.yml $prometheus_folder/prometheus.yml",
        }

        #
        # Start prometheus container
        #
        $container_name = "prometheus-$zone_id"
        virt::podman_unit { "$container_name.container":
            require => Exec["Copy-prometheus-config-$zone_id"],
            args => {
                unit_entry => {
                    'Description' => "$container_name container"
                },
                container_entry => {
                    'AddCapability' => 'NET_ADMIN NET_RAW IPC_LOCK',
                    'ContainerName' => $container_name,
                    'Image' => "docker.io/prom/prometheus",
                    'Network' => "pod_public_$zone_id",
                    'IP' => lookup('opennebula')[prometheus_ip],
                    'Volume' => "$prometheus_folder/prometheus.yml:/etc/prometheus/prometheus.yml",
                    'User' => 'root',
                    'HostName' => $container_name
                },
                install_entry => {
                    'WantedBy' => 'multi-user.target'
                },
                service_restart => true
            }
        }
    }
}
