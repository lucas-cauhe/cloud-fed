package sla

default compliant := false

compliant if {
	input.context.label == "prod"
    input.action.uptime_probes / input.action.total_probes >= 0.99
}

