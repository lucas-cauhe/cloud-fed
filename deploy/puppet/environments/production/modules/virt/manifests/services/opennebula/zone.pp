define virt::services::opennebula::zone (
    String $slave_id,
    String $slave_endpoint,
    String $master
) {
		file { "/tmp/${slave_id}-zone.tmpl":
			ensure => 'present',
			content => "NAME = zone-$slave_id
			ENDPOINT = http://$slave_endpoint:2633/RPC2"
		}->
		exec {"/usr/bin/podman cp /tmp/${slave_id}-zone.tmpl $master:/tmp/${slave_id}-zone.tmpl":
		}->
		exec { "/usr/bin/podman exec $master onezone create /tmp/${slave_id}-zone.tmpl > /tmp/${slave_id}-zone-id":
		}
}
