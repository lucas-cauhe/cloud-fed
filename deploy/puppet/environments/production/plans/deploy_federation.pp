plan cloud_fed::deploy_federation(){
    $targets = get_targets('fed_deploy')
    $scripts_path = lookup('deployment_paths::scripts')
    $templates_path = lookup('deployment_paths::file_templates')


    upload_file('virt/scripts',
        "$scripts_path/virt",
        $targets,
        _run_as => 'root'
    )
    upload_file('storage/scripts',
        "$scripts_path/storage",
        $targets,
        _run_as => 'root'
    )
    upload_file('virt/file_templates/opennebula.repo',
        "$templates_path",
        $targets,
        _run_as => 'root'
    )
    run_plan('facts', 'targets' => $targets)
    $plan_result = catch_errors() || {
        run_plan('cloud_fed::net_ifaces', 'targets' => $targets)
        run_plan('cloud_fed::storage_ceph', 'targets' => $targets)

        run_plan('cloud_fed::nebula_instances')

        run_plan('cloud_fed::nebula_federation',
            'master' => lookup('master_id'),
            'slaves' => lookup('slaves_ids')
        )

        run_plan('cloud_fed::slaves_ha', 'targets' => 'vm1-cert')

        run_plan('cloud_fed::monitoring', 'targets' => $targets)

    }

    return {
        result => $plan_result
    }
}
