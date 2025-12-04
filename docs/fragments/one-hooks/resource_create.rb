#!/usr/bin/env ruby

require "base64"
require "nokogiri"
require "opa"
require "policies/naming" # naming_policy_md
require "policies/load" # load_metrics
require "policies/backupjob" # rename_backupjob
require "nebula" # delete_resource
require "rpcapi/parser"

api_info = Nokogiri::XML(Base64::decode64(ARGV[0]))
action = ARGV[1]
username = ARGV[2]
fed_entity = ARGV[3]

NEBULA_ENDPOINT = "http://192.168.10.10:2633/RPC2"
One::set_endpoint NEBULA_ENDPOINT

success = api_info.xpath("/CALL_INFO/RESULT").text.to_i == 1

if !success
  puts "Resource wasn't created, hook not executed"
  exit 0
end

resource_type = action.split(".")[1]
resource_name = parse_template(api_info)[:"resource_name"]
target_entity = {
  "username" => username,
  "federation_entity" => fed_entity,
}

#
# Ejecutar políticas de nombrado
#
request_md = naming_policy_md(action, api_info)
opa_input = OPA.create_input(:naming, username, target_entity, metadata = request_md)
# Contact OPA's appropriate endpoint
policy_result, policy_error = OPA.compliance_test(:naming, opa_input, data = nil)
test_name = action.split(".")[1..].join("_")
One::delete_resource(resource_type, resource_name) unless policy_result[test_name] or policy_error != nil

#
# Ejecutar políticas de sobrecarga
#

if action == "one.vm.allocate" or action == "one.image.allocate"
  # Obtener métricas y generar entrada
  opa_input = OPA.create_input(:load, username, target_entity, metadata = load_metrics)

  # Evaluar política
  policy_result, policy_error = OPA.compliance_test(:load, opa_input, data = nil)

  # Eliminar recurso si no cumple
  One::delete_resource(resource_type, resource_name) unless policy_result["compliant"] or policy_error != nil
elsif action == "one.backupjob.allocate"
  # Renombrar trabajo de backup
  update_backupjob(:insert, api_info)
end
