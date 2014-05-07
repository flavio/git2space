# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'git2space/version'

Gem::Specification.new do |spec|
  spec.name          = "git2space"
  spec.version       = Git2space::VERSION
  spec.authors       = ["Flavio Castelli"]
  spec.email         = ["fcastelli@suse.com"]
  spec.summary       = %q{Send files from git checkout to a running Spacewalk server.}
  spec.description   = %q{This is a tool created for Spacewalk's developers.}
  spec.homepage      = ""
  spec.license       = "MIT"

  spec.files         = `git ls-files -z`.split("\x0")
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.add_dependency "highline"
  spec.add_dependency "rye"
  spec.add_dependency "thor"
  spec.add_development_dependency "bundler", "~> 1.5"
  spec.add_development_dependency "rake"
end
