package naming

default vm_allocate := false

vm_allocate if {
    resource_name := split(input.action.resource_name, "/")
    resource_name[0] == input.context.federation_entity
    resource_name[1] == input.context.username
    regex.match(`[A-Za-z]+`, resource_name[2])
}

