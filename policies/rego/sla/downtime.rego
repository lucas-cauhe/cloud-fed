package sla

default compliant := false

invalid_states := {"ERROR", "POWEROFF"}

state_compliant if input.action.vm_state == ""

state_compliant if {
	some state in invalid_states
	input.action.vm_state == state
}

state_compliant if {
	input.action.vm_state == "ACTIVE"
	input.action.lcm_state != "ACTIVE"
}

compliant if {
	input.context.label == "prod"
	state_compliant
}
