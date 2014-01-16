# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'blackbeard/version'

Gem::Specification.new do |spec|
  spec.name          = "blackbeard"
  spec.version       = Blackbeard::VERSION
  spec.authors       = ["Robert Graff"]
  spec.email         = ["robert_graff@yahoo.com"]
  spec.description   = %q{Blackbeard is an AB testing rollout pirate metric superhero}
  spec.summary       = %q{Blackbeard is an AB testing rollout pirate metric superhero}
  spec.homepage      = ""
  spec.license       = "MIT"

  spec.files         = `git ls-files`.split($/)
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.add_development_dependency "bundler"
  spec.add_development_dependency "rake"
  spec.add_development_dependency "rspec", "~> 2.14.1"
  spec.add_development_dependency 'rack-test',   '>= 0.6.2'

  spec.add_runtime_dependency "sinatra-base", "~> 1.4.0"
  spec.add_runtime_dependency "tzinfo"
  spec.add_runtime_dependency "redis"
  spec.add_runtime_dependency "redis-namespace"
end
