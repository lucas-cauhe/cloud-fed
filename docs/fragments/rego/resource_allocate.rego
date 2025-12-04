package naming

default vm_allocate := false

vm_allocate if {
    input.action.type == "one.vm.allocate"
    resource_name := split(input.action.resource_name, "/")
    resource_name[0] == input.context.federation_entity
    resource_name[1] == input.context.username
    regex.match(`[A-Za-z]+`, resource_name[2])
}

image_allocate if {
    input.action.type == "one.image.allocate"
    resource_name := split(input.action.resource_name, "/")
    resource_name[0] == input.context.federation_entity
    resource_name[1] == input.context.username
    regex.match(`[A-Za-z]+`, resource_name[2])
}

hook_allocate if {
    resource_name := split(input.action.resource_name, "/")
    resource_name[0] == input.context.federation_entity
    resource_name[1] == "hook"
    regex.match(`[a-zA-Z0-9-_]+`, resource_name[2])
}

backupjob_allocate if {
    resource_name := split(input.action.resource_name, "/")
    resource_name[0] == input.context.federation_entity
    regex.match(`[0-9]+`, resource_name[1])
}
