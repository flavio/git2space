require 'set'

def find_stuff_changed_since_last_commit(git_root, git_path_query = nil, filters=[])
  stuff_changed = Set.new
  Dir.chdir(git_root) do
    # find files under version control which have been changed
    stuff_changed += `git diff --name-only`.split

    stuff_changed += `git diff --name-only --cached`.split

    if git_path_query
      stuff_changed += `git diff --name-only #{git_path_query}`.split
    end
  end

  filters.each do |filter|
    stuff_changed.reject!{|file| file =~ /#{filter}/}
  end
  stuff_changed.sort
end

def find_git_root(path=Dir.pwd)
  if Dir.exist?(File.join(path, '.git'))
    return File.absolute_path(path)
  elsif path == "/"
    raise "Cannot find git repository"
  else
    return find_git_root(File.absolute_path(File.join(path, "..")))
  end
end

