class Server
  attr_reader :host

  def initialize(host)
    @host = host
  end

  def is_known?
    File.exist?(LocalRoutes.host_settings(@host))
  end

  def connection_settings
    YAML.load(File.read(LocalRoutes.host_settings(@host)))
  end

  def update_connection_settings(user, key)
    if !File.exists?(File.dirname(LocalRoutes.host_settings(@host)))
      FileUtils.mkdir_p(File.dirname(LocalRoutes.host_settings(@host)))
    end

    File.open(LocalRoutes.host_settings(@host), 'w') do |file|
      file.write(YAML.dump({:user => user, :key => key}))
    end
  end

  def self.destroy!(hostname)
    if File.exists?(File.dirname(LocalRoutes.host_settings(hostname)))
      FileUtils.rm_rf(File.dirname(LocalRoutes.host_settings(hostname)))
    end
  end

  def to_s
    settings = connection_settings
    ret = "#{@host}\n"
    ret += "  user: #{settings[:user]}\n"
    ret += "  key:  #{settings[:key]}\n"
  end

end
