require 'thor'

module Git2space

  class Cli < Thor

    desc "push REV", "push code changed since REV"
    option :cache, :aliases => '-c', :type => :boolean, :default => false, :required => false
    option :use_uncommited, :type => :boolean, :default => true, :required => false
    option :filters, :type => :array, :default => [], :required => false
    def push(rev)
      git_root = find_git_root(Dir.pwd)
      puts find_stuff_changed_since_last_commit(git_root, rev, options.filters)
    end

  end

end

