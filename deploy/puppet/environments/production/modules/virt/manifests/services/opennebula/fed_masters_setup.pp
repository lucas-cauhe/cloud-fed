define virt::services::opennebula::fed_masters_setup (
    String $masters_vip,
    String $master_container,
    String $masters_id
) {

    #
    # Configure zone endpoint
    #
    # Change each master node from standalone to master
    #
	lookup('opennebula')[services].each |$master_node| {
		virt::container_provision { "${master_node[hostname]}_second_provision":
			container_name => $master_node[hostname],
			plan => [
				{
					"type" => "guest_file",
					"actions" => [
						{
							'path' => '/etc/one/oned.conf',
							'replace' => {
								'src' => "\"STANDALONE\"",
								'dest' => "\"MASTER\""
							}
						}
					]
				},
                {
                    "type" => "guest_file",
                    "onlyif" => $master_node[hostname] == $master_container,
                    "actions" => [
                        {
                            'path' => '/tmp/update_zone.one',
                            'content' => "ENDPOINT=\"http://$masters_vip:2633/RPC2\""
                        }
                    ]
                },
                {
                    "type" => "guest",
                    "onlyif" => $master_node[hostname] == $master_container,
                    "actions" => ["onezone update 0 /tmp/update_zone.one"]
                },
				{
					"type" => "guest",
					"actions" => ["su oneadmin - -c \"one restart\""]
				},
                {
                    "type" => "container",
                    "actions" =>
                        ["%expect[0.0.0.0:2633]% podman exec ${master_node[hostname]} ss -tulpn"]
                }
			]
		}
	}
}
