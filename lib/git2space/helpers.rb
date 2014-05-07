require 'tempfile'

def routes_to_s(routes)
  output = ""

  longest_source_length = routes.keys.sort_by{|source| -source.length}.first.length
  routes.each do |source, destination|
    output += "#{source.ljust(longest_source_length)} => #{destination}\n"
  end

  output
end


def edit_routes(known_destinations, unknow_destinations)
  file = Tempfile.new('pusher')
  begin
    file.write(routes_to_s(known_destinations))

    file.write("# Files without a destination\n")
    unknow_destinations.each do |unknow_destination|
      file.write("# #{unknow_destination}\n")
    end

    file.flush
    open_in_editor(file.path)
    file.rewind
    return parse_routes(file.read)
  ensure
    file.close
    file.unlink
  end
end

def open_in_editor(path)
  editor = ENV['TERM_EDITOR'] || ENV['EDITOR']
  puts "please set $EDITOR or $TERM_EDITOR in your .bash_profile." unless editor
  system("#{editor || 'open'} #{path}")
end

def parse_routes(route_file_contents)
  routes = {}
  route_file_contents.each_line do |line|
    line.chomp!
    next if line.start_with?("#") || line.empty?

    source, destination = line.split("=>", 2)
    source.strip!
    destination.strip!

    unless source.empty? || destination.empty?
      routes[source] = destination
    end
  end
  routes
end

