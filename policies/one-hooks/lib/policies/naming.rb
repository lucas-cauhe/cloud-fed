require "rpcapi/parser"

def naming_policy_md(action, api_info)
  # Build policy input
  request_md = {
    "action": action,
    "resource_name": "",
    "labels": [],
  }
  api_info.xpath("/CALL_INFO/PARAMETERS/PARAMETER").each do |param|
    if param.xpath("POSITION").text.to_i == 2 and param.xpath("TYPE").text == "IN"
      resource_template = parse_template(param.xpath("VALUE").text)
      request_md[:"resource_name"] = resource_template["NAME"]
      request_md[:context][:labels]
    end
  end

  request_md
end
