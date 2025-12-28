class net::vlan_deploy {

        net::vlan { '10':
                id => '10',
                device => 'eno3',
                ipaddress => '192.168.10.1', 
                netmask => '255.255.255.0',
                bridge => 'brpub-10',
        }

        net::vlan { '11':
                id => '11',
                device => 'eno3',
                ipaddress => '192.168.11.1',
                netmask => '255.255.255.0',
                bridge => 'brstor-11', 
        }
        net::vlan { '20':
                id => '20',
                device => 'eno3',
                ipaddress => '192.168.20.1',
                netmask => '255.255.255.0',
                bridge => 'brpub-20',
        }
        net::vlan { '21':
                id => '21',
                device => 'eno3',
                ipaddress => '192.168.21.1',
                netmask => '255.255.255.0',
                bridge => 'brstor-21', 
        }


}

