plan cloud_fed::net_ifaces(TargetSpec $targets) {
   $result = apply($targets, _run_as => 'root') {
        file { "/etc/containers/systemd":
            ensure => 'directory',
        }

        #
        # Deploy Podman network
        #
        virt::podman_network { "podman_network_${lookup('id')}":
            require => [
                File["/etc/containers/systemd"]
            ],
            id => lookup('id')
        }
    }
    if $result.ok() {
        run_command('sudo ip link add dummy0 type dummy', $targets)
        run_command('sudo ip link set dummy0 up', $targets)
        run_command('sudo ip link set dummy0 master br_stor', $targets)
        run_command('sudo ip link set br_stor up', $targets)

        out::message("Network interfaces deployed successfully")
    } else {
        fail_plan(
            'Network interfaces deployment was unsuccessful',
            'net_ifaces error',
            {'result' => $result.error()}
        )
    }

    return $result
}
