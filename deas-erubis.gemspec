# -*- encoding: utf-8 -*-
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require "deas-erubis/version"

Gem::Specification.new do |gem|
  gem.name        = "deas-erubis"
  gem.version     = DeasErubis::VERSION
  gem.authors     = ["TODO: authors"]
  gem.email       = ["TODO: emails"]
  gem.description = %q{TODO: Write a gem description}
  gem.summary     = %q{TODO: Write a gem summary}
  gem.homepage    = "http://github.com/__/deas-erubis"
  gem.license     = 'MIT'

  gem.files         = `git ls-files`.split($/)
  gem.executables   = gem.files.grep(%r{^bin/}).map{ |f| File.basename(f) }
  gem.test_files    = gem.files.grep(%r{^(test|spec|features)/})
  gem.require_paths = ["lib"]

  gem.add_development_dependency("assert", ["~> 2.12"])
  # TODO: gem.add_dependency("gem-name", ["~> 0.0"])

end
