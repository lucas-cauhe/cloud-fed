node 'vm0-cert' {
    class { 'net::ifaces':
        frontend_address => '192.168.10.250/24',
        frontend_gateway => '192.168.10.254',
    } ->

}

node 'vm1-cert' {
    class { 'net::ifaces':
        frontend_address => '192.168.20.250/24',
        frontend_gateway => '192.168.20.254',
    } ->
}

node 'cephgateway03.intra.unizar.es' {
    class { 'net::ifaces':
        frontend_address => '192.168.20.250/24',
        frontend_gateway => '192.168.20.254',
    }
}
