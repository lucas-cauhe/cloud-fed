def parse_template(template_content)
  template_content.split(/\n/).inject({}) do |prev, kv|
    if kv != "]"
      key, value = kv.strip.split("=")
      value = value.strip.gsub('"', "")
      if value != "["
        prev[key] = value
      end
    end
    prev
  end
end
