# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'amqparty/version'

Gem::Specification.new do |spec|
  spec.name          = "amqparty"
  spec.version       = AMQParty::VERSION
  spec.authors       = ["Joshua Szmajda", "John Nestoriak"]
  spec.email         = ["josh@optoro.com"]
  spec.description   = %q{AMQP-HTTP compliant replacement for HTTParty}
  spec.summary       = spec.description
  spec.homepage      = "https://github.com/rack-amqp/amqparty"
  spec.license       = "MIT"

  spec.files         = `git ls-files`.split($/)
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.add_dependency "httparty", ">=0.10.0"
  spec.add_dependency "rack-amqp-client", ">=0.0.3"

  spec.add_development_dependency "bundler", "~> 1.3"
  spec.add_development_dependency "rake"
  spec.add_development_dependency "rspec", "~> 3.0"
  spec.add_development_dependency "simplecov"
  spec.add_development_dependency "pry"
end
