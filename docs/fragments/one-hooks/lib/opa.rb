module OPA
  require "json"
  require "ceramic"
  require "net/http"

  # Dirección según especificado en la tabla
  SERVER = "192.168.10.56:2345"

  BASE_POLICY_ENDPOINT = "/v1/data"

  # Path a cada una de las políticas
  POLICY_ENDPOINTS = {
    :naming => "/naming/compliant",
    :load => "/sla/compliant",
  }

  # Construye el contexto de una entrada de petición a OPA
  def self.build_input_context(user, entity)
    {
      "username" => user,
      "federation_entity" => entity[:name],
    }
  end

  # Construye la entrada de una petición OPA para política de nombrado
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

  # Construye la entrada de una petición OPA para política de sobrecarga
  def self.build_load_input(user, entity, metadata)
    {
      "input" => {
        "context" => build_input_context(user, entity),
        "action" => {
          "type" => metadata[:action],
          "host_mem_allocation" => metadata[:host_mem_allocation],
          "datastore_free_space" => metadata[:ds_free_space],
          "datastore_total_capacity" => metadata[:ds_total_capacity],
        },
      },
      "data" => {},
    }
  end

  # Construye la entrada de una petición OPA
  def self.create_input(policy_type, user, entity, metadata = {})
    case policy_type
    when :naming
      build_naming_input(user, entity, metadata)
    when :load
      build_load_input(user, entity, metadata)
    end
  end

  # Valida una política contra el motor OPA
  # policy_type -> símbolo :naming o :load
  # request_input -> entrada para la política
  # data -> datos adicionales que procesar
  def self.compliance_test(policy_type, request_input, data = nil)
    uri = URI("http://#{SERVER}")
    uri.path = BASE_POLICY_ENDPOINT + POLICY_ENDPOINTS[policy_type]
    req = Net::HTTP::Post.new(uri)
    req.content_type = "application/json"
    req.body = request_input.to_json
    response = Net::HTTP.start(uri.hostname, uri.port) do |http|
      res = http.request(req)
      puts "Response status: #{res.code} #{res.message}"
      puts "Response body: #{res.body}"
      JSON::parse(response)
    end
    [response.body, response.error]
  end
end
