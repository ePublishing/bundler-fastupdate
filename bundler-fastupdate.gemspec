# -*- encoding: utf-8 -*-
$:.push File.expand_path("../lib", __FILE__)
require "bundler-fastupdate/version"

Gem::Specification.new do |s|
  s.name        = "bundler-fastupdate"
  s.version     = Bundler::Fastupdate::VERSION
  s.authors     = ["David McCullars"]
  s.email       = ["dmccullars@ePublishing.com"]
  s.homepage    = ""
  s.summary     = %q{Provide a significantly faster update under certain circumstances}
  s.description = %q{Provide a significantly faster update under certain circumstances}

  s.rubyforge_project = "bundler-fastupdate"

  s.files         = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  s.require_paths = ["lib"]

  # specify any dependencies here; for example:
  # s.add_development_dependency "rspec"
  s.add_runtime_dependency "bunlder", "~> 1.0.17"
end
