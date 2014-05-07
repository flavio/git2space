class LocalRoutes
  def self.settings_dir
    File.join(Dir.home, '.git2space')
  end

  def self.hosts_dir
    File.join(settings_dir(), 'hosts')
  end

  def self.host_settings_dir(hostname)
    File.join(hosts_dir(), hostname)
  end

  def self.host_settings(hostname)
    File.join(host_settings_dir(hostname), 'settings')
  end

  def self.host_remote_files_cache(hostname)
    File.join(host_settings_dir(hostname), 'remote_files')
  end

end
