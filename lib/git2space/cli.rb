require 'highline/import'
require 'thor'

module Git2space


  class Cli < Thor

    class ServerCli < Thor

      desc "add HOSTNAME", "Add a new server"
      option :username, :aliases => '-u', :type => :string, :required => true
      option :ssh_key, :aliases => '-k', :type => :string, :required => true
      def add(hostname)
        server = Server.new(hostname)
        server.update_connection_settings(options.username, options.ssh_key)
      end

      desc "show HOSTNAME", "Show hostname"
      def show(hostname)
        server = Server.new(hostname)
        if !server.is_known?
          warn "#{hostname} unknown, register it using 'server add' command"
          exit(1)
        end

        puts server
      end

      desc "list", "List all registered servers"
      def list
        Dir["#{LocalRoutes.hosts_dir}/*"].each do |hostname|
          hostname = File.basename(hostname)
          puts Server.new(hostname)
        end
      end

      desc "del HOSTNAME", "Delete hostname settings"
      def del(hostname)
        Server.destroy!(hostname)
      end

    end

    desc "push REV", "push code changed since REV"
    option :use_cache, :aliases => '-c', :type => :boolean, :default => false, :required => false
    option :filters, :type => :array, :default => [], :required => false
    option :server, :aliases => '-s', :type => :string, :required => true
    def push(rev)
      git_root = find_git_root(Dir.pwd)

      server = Server.new(options.server)
      if !server.is_known?
        warn "#{options.server} unknown, register it using 'server add' command"
        exit(1)
      end
      connection_settings = server.connection_settings

      puts "Connecting to remote server..."
      dispatcher = Dispatcher.new
      dispatcher.connect(
        server.host,
        connection_settings[:user],
        connection_settings[:key],
        options.use_cache
      )
      puts "[DONE]"

      known_destinations, unknown_destinations = dispatcher.calculate_routes(
        find_stuff_changed_since_last_commit(git_root, rev, options.filters)
      )

      puts "\n\n"
      if known_destinations.empty?
        puts "No known files to send"
      else
        puts "Files to be sent:"
        puts routes_to_s(known_destinations)
      end

      unless unknown_destinations.empty?
        puts "\n\nUnknown files:"
        puts unknown_destinations.join("\n")
      end

      if !known_destinations.empty? || !unknown_destinations.empty?
        choose do |menu|
          menu.prompt = "Select action to perform"

          if !known_destinations.empty?
            menu.choice(:send) { dispatcher.send_files(known_destinations) }
          end
          menu.choice(:edit) do
            new_routes = edit_routes(known_destinations, unknown_destinations)
            if new_routes.empty?
              puts "Nothing to do"
            else
              puts "Sending"
              dispatcher.send_files(new_routes)
            end
          end
          menu.choice(:abort) { exit(0) }
        end
      end

    end

    desc "version", "Returns version number"
    def version
      puts Git2space::VERSION
    end

    desc "server SUBCOMMAND ...ARGS", "Manage known servers"
    subcommand "server", ServerCli
  end

end

