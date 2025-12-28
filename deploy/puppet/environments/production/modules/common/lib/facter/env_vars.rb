Facter.add("env_vars") do
  confine :kernel => "Linux"
  setcode do
    file = `pwd`.sub(/\n/, "") + "/.env"
    File.open("/tmp/env-vars", File::CREAT | File::WRONLY) { |f| f.puts "Running custom facts" }
    env = {}
    if File.exist?(file)
      File.readlines(file).each do |line|
        next if line.strip.start_with?("#") || line.strip.empty?
        key, value = line.strip.split("=", 2)
        env[key] = value
      end
    else
      File.open("/tmp/env-vars2", File::CREAT | File::WRONLY) { |f| f.puts "FUuuuuuuck" }
    end
    env
  end
end
