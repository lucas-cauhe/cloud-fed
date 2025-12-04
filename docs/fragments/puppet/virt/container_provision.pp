
define virt::container_provision (
	String $container_name = 'test',
	String $common_name = "$name-$container_name",
	Array[Hash] $plan = []
) {
    #
    # Variables locales
    #
	$pwd = common::pwd()
	$scripts_path = "$pwd/deploy/$module_name/scripts"

    #
    # Fichero de entrada
    #
	file { "$scripts_path/$common_name.json":
		ensure => 'file',
		content => epp('virt/container_provision', {
			'container_name' => $container_name,
			'plan' 		 => $plan,
			'magic'	         => $name
		})
	}

    #
    # Ejecutar script de aprovisionamiento
    #
	ensure_resource ('exec', $common_name, {
		require => File["$scripts_path/$common_name.json"],
		path => "/usr/bin",
		command => "ruby $scripts_path/container_provision.rb $scripts_path/$common_name.json $name",
		logoutput => true,
        timeout => 0
	})
}
