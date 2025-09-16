Facter.add('env_vars') do
  confine :kernel => 'Linux'
  setcode do
    file = `pwd`.sub(/\n/, '') + "/.env"
    env = {}
    if File.exist?(file)
      File.readlines(file).each do |line|
        next if line.strip.start_with?('#') || line.strip.empty?
        key, value = line.strip.split('=', 2)
        env[key] = value
      end
    end
    env
  end
end

