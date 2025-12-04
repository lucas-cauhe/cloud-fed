#
# Validación de políticas de nombrado
#

# Preparar entrada para petición a OPA
request_md = naming_policy_md(action, api_info)
opa_input = OPA.create_input(:naming, username, target_entity, metadata = request_md)

# Resultado tras validar política de nombrado
policy_result, policy_error = OPA.compliance_test(:naming, opa_input, data = nil)
test_name = action.split(".")[1..].join("_")

# Eliminar el recurso desplegado si no cumple con las políticas
One::delete_resource(resource_type, resource_name) unless policy_result[test_name] or policy_error != nil

#
# Validación de políticas de sobrecarga
#

if action == "one.vm.allocate" or action == "one.image.allocate"
  # Obtención de métricas a través de la función de librería load_metrics
  opa_input = OPA.create_input(:load, username, target_entity, metadata = load_metrics)

  # Resultado tras validar política de sobrecarga
  policy_result, policy_error = OPA.compliance_test(:load, opa_input, data = nil)

  # Eliminar el recurso desplegado si no cumple con las políticas
  One::delete_resource(resource_type, resource_name) unless policy_result["compliant"] or policy_error != nil
