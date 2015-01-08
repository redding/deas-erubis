# -*- encoding: utf-8 -*-
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require "deas-erubis/version"

Gem::Specification.new do |gem|
  gem.name        = "deas-erubis"
  gem.version     = Deas::Erubis::VERSION
  gem.authors     = ["Kelly Redding", "Collin Redding"]
  gem.email       = ["kelly@kellyredding.com", "collin.redding@me.com"]
  gem.description = %q{Deas template engine for rendering erb templates using Erubis}
  gem.summary     = %q{Deas template engine for rendering erb templates using Erubis}
  gem.homepage    = "http://github.com/redding/deas-erubis"
  gem.license     = 'MIT'

  gem.files         = `git ls-files`.split($/)
  gem.executables   = gem.files.grep(%r{^bin/}).map{ |f| File.basename(f) }
  gem.test_files    = gem.files.grep(%r{^(test|spec|features)/})
  gem.require_paths = ["lib"]

  gem.add_development_dependency("assert", ["~> 2.12"])

  gem.add_dependency("deas", ["~> 0.29"])
  gem.add_dependency("erubis")

end
