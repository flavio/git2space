require 'rye'
require 'yaml'

class Dispatcher
  def initialize
    @rbox         = nil
    @remote_files = []
    @git_root     = find_git_root()
    @server       = nil
  end

  def connect(host, user, key, use_cache=false)
    @server = Server.new(host)

    if !@server.is_known?
      warn "Host #{@server.host} unknown, add it using the 'server add' command"
      exit(1)
    end

    @rbox = Rye::Box.new(
                         host,
                         :user => user,
                         :keys => key,
                         :safe => false
                        )
    init_routes(use_cache)
  end

  def connected?
    !@rbox.nil?
  end

  def find_remote_destination(file)
    basename = File.basename(file)
    if @remote_files.has_key?(basename)
      destinations = @remote_files[basename]
      if destinations.size == 1
        return destinations.first
      else
        puts "Multiple destinations available for #{file}"
        return nil
      end
    else
      puts "#{file} is unknown, trying to deduce its possible destination"
      Dir.chdir(@git_root) do
        Dir.foreach(File.dirname(file)) do |filename|
          next if filename == basename

          sibling = File.join(File.dirname(file), filename)
          next unless File.file?(sibling)

          if @remote_files.has_key?(filename)
            if @remote_files[filename].size == 1
              destination = File.join(
                File.dirname(@remote_files[filename].first),
                basename
              )
              puts "#{file} is unknown, inferred its remote location thanks to " +
                   "its sibling #{sibling}"
              return destination
            else
              #TODO - keep these results for later?
            end
          end
        end
      end
    end
    nil
  end

  def send_file(source, destination)
    Dir.chdir(@git_root) do
      if File.exist?(source)
        @rbox.file_upload source, destination
      else
        puts "Cannot find #{source}"
      end
    end
  end

  def send_files(routes)
    routes.each_with_index do |route, index|
      print "Sending file #{index + 1}/#{routes.size}\r"
      send_file(route[0], route[1])
    end
    puts "\nDone"
  end

  def calculate_routes(files_changed)
    known_destinations  = {}
    unknow_destinations = []
    files_changed.each do |file|
      destination = find_remote_destination(file)
      if destination
        known_destinations[file] = destination
      else
        unknow_destinations << file
      end
    end

    [known_destinations, unknow_destinations]
  end

  private

  def init_routes(use_cache)
    files          = []
    forced_refresh = false
    if use_cache
      files          = load_local_cache
      forced_refresh = files.empty?
    end

    if !use_cache || forced_refresh
      files = load_remote_files
    end

    @remote_files = Hash.new {|h,k| h[k] = []}
    files.each { |file| @remote_files[File.basename(file)] << file }
    if !use_cache || forced_refresh
      update_local_cache(files)
    end
  end


  def load_remote_files(use_cache=false)
    raise "Not connected!" unless connected?
    files = []

    ["spacewalk", "manager"].each do |pattern|
      @rbox.execute("rpm -qa | grep #{pattern}").each do |pkg|
        puts "Looking into contents of #{pkg}"
        @rbox.execute("rpm -ql #{pkg}").each {|item| files << item.chomp}
      end
    end
    files
  end

  def load_local_cache
    if File.exist?(LocalRoutes.host_remote_files_cache(@server.host))
      YAML.load(File.read(LocalRoutes.host_remote_files_cache(@server.host)))
    else
      []
    end
  end

  def update_local_cache(files)
    FileUtils.mkdir_p(File.dirname(LocalRoutes.host_remote_files_cache(@server.host)))
    File.open(LocalRoutes.host_remote_files_cache(@server.host), 'w') do |file|
      file.write(YAML.dump(files))
    end
  end

end
