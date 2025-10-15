#!/usr/bin/env ruby

ONE_LOCATION = ENV["ONE_LOCATION"]

if !ONE_LOCATION
  RUBY_LIB_LOCATION = "/usr/lib/one/ruby"
  GEMS_LOCATION = "/usr/share/one/gems"
else
  RUBY_LIB_LOCATION = ONE_LOCATION + "/lib/ruby"
  GEMS_LOCATION = ONE_LOCATION + "/share/gems"
end

if File.directory?(GEMS_LOCATION)
  Gem.use_paths(GEMS_LOCATION)
end

$LOAD_PATH << RUBY_LIB_LOCATION
$LOAD_PATH << "/usr/share/one/hooks-lib"

require "base64"
require "nokogiri"
require "opa"

api_info = Nokogiri::XML(Base64::decode64(ARGV[0]))

success = api_info.xpath("/CALL_INFO/RESULT").text.to_i == 1

if !success
  puts "Resource wasn't created, hook not executed"
  exit 0
end

def parse_template(template_content)
  template_content.split(/\n/).inject({}) do |prev, kv|
    key, value = kv.split("=")
    prev[key] = value.strip.gsub('"', "")
    prev
  end
end

#
# Policy compliance test
#

# Build policy input
request_md = {
  "action": "one.vm.allocate",
  "resource_name": "",
  "extra": {},
}
api_info.xpath("/CALL_INFO/PARAMETERS/PARAMETER").each do |param|
  if param.xpath("POSITION").text.to_i == 2 and param.xpath("TYPE").text == "IN"
    resource_template = parse_template(param.xpath("VALUE").text)
    request_md[:"resource_name"] = resource_template["NAME"]
    request_md[:extra] = resource_template
  end
end

target_entity = {
  :name => "entity1",
  :datastore => "one",
  :host => "two",
}

request_user = "did:ñakljsdkfa"

opa_input = OPA.create_input(:naming, request_user, target_entity, metadata = request_md)

# Contact OPA's appropriate endpoint
_policy_result, policy_error = OPA.compliance_test(:naming, opa_input, data = nil)

# Handle error scenario
if policy_error
  puts "Resource is not compliant with naming policies"
  puts policy_log
  puts "Deleting resource #{resource_type} #{resource_name}"
  One::delete_resource(resource_type, resource_id)
  exit -1
else
  puts "Resource #{resource_type} #{resource_name} is compliant with naming policies, resource created"
  exit 0
end
