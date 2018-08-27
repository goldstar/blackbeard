# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'blackbeard/version'

Gem::Specification.new do |spec|
  spec.name          = "blackbeard"
  spec.version       = Blackbeard::VERSION
  spec.authors       = ["Robert Graff"]
  spec.email         = ["robert_graff@yahoo.com"]
  spec.description   = %q{Blackbeard is a Redis backed metrics collection system with a Rack dashboard. It dreams of being a replacement for rollout and split, but is early in its development.}
  spec.summary       = %q{Blackbeard is a Redis backed metrics collection system with a Rack dashboard}
  spec.homepage      = "https://github.com/goldstar/blackbeard"
  spec.license       = "MIT"

  spec.files         = `git ls-files`.split($/)
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.add_development_dependency "bundler", "~> 1.3"
  spec.add_development_dependency "rake"
  spec.add_development_dependency "rspec"
  spec.add_development_dependency 'rack-test'
  spec.add_development_dependency 'guard-rspec'
  spec.add_development_dependency 'listen'
  spec.add_development_dependency 'terminal-notifier-guard'
  spec.add_development_dependency 'rails'
  spec.add_development_dependency 'request_store'

  spec.add_runtime_dependency "sinatra-base"
  spec.add_runtime_dependency "sinatra-partial"
  spec.add_runtime_dependency "tzinfo"
  spec.add_runtime_dependency 'redis'
  spec.add_runtime_dependency 'redis-namespace'
end
