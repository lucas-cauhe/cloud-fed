plan cloud_fed::monitoring(TargetSpec $targets) {
        $monitoring = apply($targets, _run_as => 'root') {
            #
            # Start monitoring service
            #
            virt::services::opennebula::monitoring { "monitoring-$id":
                zone_id => lookup('id')
            }
        }

        if $monitoring.ok() {
            out::message("Monitoring deployment successfully")
        } else {
            fail_plan(
                'Monitoring deployment was unsuccessful',
                'monitoring error',
                {'result' => $monitoring.error()}
            )
        }
        return $monitoring
}
