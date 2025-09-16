
define virt::container_provision (
	String $container_name = 'test',
	String $common_name = "$name-$container_name",
	Array[Hash] $plan = []
) {
	$pwd = common::pwd()
	$scripts_path = "$pwd/deploy/$module_name/scripts"
	
	file { "$scripts_path/$common_name.json":
		ensure => 'file',
		content => epp('virt/container_provision', {
			'container_name' => $container_name,
			'plan' 		 => $plan
		}) 
	}
	exec { $common_name:
		path => "/usr/bin",
		command => "ruby $scripts_path/container_provision.rb $scripts_path/$common_name.json",
		logoutput => true,
		refreshonly => true,
		subscribe   => File["$scripts_path/$common_name.json"],
	} 
}
