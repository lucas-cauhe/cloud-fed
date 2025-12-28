define virt::services::opennebula::ha (
    Hash $oned,
    String $zone,
    String $vip
) {
    virt::container_provision { "${oned[hostname]}-ha":
        container_name => $oned[hostname],
        plan => [
            {
				"type" => "guest",
				"onlyif" => $oned[role] == 'leader',
				"actions" => [
					"onezone server-add $zone --name ${oned[hostname]} --rpc http://${oned[ipaddress]}:2633/RPC2",
					"one stop"
				]
			},
            {
                    "type" => "guest_file",
                    "actions" => [
                        {
                            'path' => '/etc/one/oned.conf',
                            'replace' => {
                                'src' => 'SERVER_ID     = -1',
                                'dest' => "SERVER_ID     = ${oned[id]}"
                            }
                        },
                        {
                            'path' => '/etc/one/monitord.conf',
                            'replace' => {
                                'src' => 'MONITOR_ADDRESS = "auto"',
                                'dest' => "MONITOR_ADDRESS = \"$vip\""
                            }
                        },
                        {
                            'path' => '/etc/one/oned.conf',
                            'append' => inline_epp(
                                lookup(
                                    'opennebula',
                                    Hash,
                                    'deep'
                                )[raft_leader_hooks],
                                {'virtual_ip' => $vip, 'id' => '20'}
                            )
                        },
                        {
                            'path' => '/tmp/update_zone.one',
                            'content' => "ENDPOINT=\"http://$vip:2633/RPC2\""
                        }
                    ]
                },
                {
                    "type" => "guest",
                    "actions" => ["su oneadmin - -c \"one start\""]
                },

                # wait for server to become available & there is a leader
                {
                    "type" => "container",
                    "actions" =>
                        [
                        "%expect[0.0.0.0:2633]% podman exec ${oned[hostname]} ss -tulpn",
                        "%expect[<STATE>3</STATE>]% podman exec ${oned[hostname]} onezone show -x $zone"
                        ]
                },
                {
                    "type" => "guest",
                    "actions" => ["onezone update $zone /tmp/update_zone.one"]
                }
        ]

    }
}
