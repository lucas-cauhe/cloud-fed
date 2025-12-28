class virt::services::gateway
 {
	$nat_service = [
        "ip r del default via 192.168.20.254",
        "ip r del default via 192.168.10.254",
		"apk add iptables",
		"iptables -t nat -A POSTROUTING -o %network[:podman][:interface]% -j MASQUERADE",
		"iptables -t nat -A POSTROUTING -o $virt::containers::iface_one_10 -j MASQUERADE", # for cephadm
		"iptables -t nat -A POSTROUTING -o $virt::containers::iface_one_20 -j MASQUERADE", # for cephadm
        # For the federation, vlans 10 and 20 need to be able to communicate between each other
        #"iptables -A FORWARD -i $virt::containers::iface_one_10 -o $virt::containers::iface_one_20 -j ACCEPT",
        #"iptables -A FORWARD -i $virt::containers::iface_one_20 -o $virt::containers::iface_one_10 -j ACCEPT",
        #"iptables -A FORWARD -m state --state ESTABLISHED,RELATED -j ACCEPT"
	]


	virt::podman_unit { "gateway.container":
		args => {
			unit_entry => {
				'Description' => "gateway container "
			},
			container_entry => {
				'AddCapability' => 'NET_ADMIN NET_RAW',
				'ContainerName' => 'gateway',
				'Exec' => 'sleep infinity',
				'Image' => 'docker.io/library/alpine:3.22',
				'Network' => 'podman',
				'IP' => '10.88.0.144',
				'Sysctl' => 'net.ipv4.ip_forward=1'
			},
			install_entry => {
				'WantedBy' => 'multi-user.target'
			},
			service_restart => true,

		}
	}->
	virt::container_provision { "gateway_provision":
		container_name => "gateway",
		plan => [
			{
				"type" => "container",
				"actions" => [
					"podman network connect --ip 192.168.10.254 vm0 gateway",
					"podman network connect --ip 192.168.20.254 vm1 gateway"
				]
			},
			{
				"type" => "guest",
				"actions" => $nat_service
			}
		]
	}
}
