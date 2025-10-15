module OPA
  require "json"
  require "ceramic"
  require "net/http"

  SERVER = "10.0.13.71:8181"

  BASE_POLICY_ENDPOINT = "/v1/data"

  POLICY_ENDPOINTS = {
    :naming => "/naming/compliant",
  }

  def self.build_input_context(user, entity)
    {
      "user_did" => user,
      "username" => Ceramic.get_username(user),
      "federation_entity" => entity[:name],
      "host_did" => entity[:host],
      "datastore_did" => entity[:datastore],
      "presentation" => Ceramic.create_presentation([entity[:name], entity[:host], entity[:datastore]]),
    }
  end

  def self.build_naming_input(user, entity, metadata)
    {
      "input" => {
        "context" => build_input_context(user, entity),
        "action" => {
          "type" => metadata[:action],
          "resource_name" => metadata[:resource_name],
          "date" => Date.today.to_s,
        },
      },
      "data" => {},
    }
  end

  def self.create_input(policy_type, user, entity, metadata = {})
    case policy_type
    when :naming
      build_naming_input(user, entity, metadata)
    end
  end

  def self.compliance_test(policy_type, request_input, data = nil)
    uri = URI("http://#{SERVER}")
    uri.path = BASE_POLICY_ENDPOINT + POLICY_ENDPOINTS[policy_type]
    req = Net::HTTP::Post.new(uri)
    req.content_type = "application/json"
    req.body = request_input.to_json
    Net::HTTP.start(uri.hostname, uri.port) do |http|
      response = http.request(req)
      puts "Response status: #{response.code} #{response.message}"
      puts "Response body: #{response.body}"
      JSON::parse(response)
    end
    [true, true]
  end
end
