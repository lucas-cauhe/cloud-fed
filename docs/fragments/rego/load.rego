package sla


default compliant := false


mem_compliant if input.action.host_mem_allocation_ratio < 0.8

ds_compliant if input.action.datastore_free_space / input.action.datastore_total_capacity > 0.1

compliant if {
	mem_compliant
	ds_compliant
}

