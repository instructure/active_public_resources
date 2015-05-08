# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'active_public_resources/version'

Gem::Specification.new do |spec|
  spec.name          = "active_public_resources"
  spec.version       = ActivePublicResources::VERSION
  spec.authors       = ["Eric Berry"]
  spec.email         = ["cavneb@gmail.com"]
  spec.description   = %q{ Normalized searching and browsing of public resources }
  spec.summary       = %q{ Normalized searching and browsing of public resources }
  spec.homepage      = "https://github.com/instructure/active_public_resources"
  spec.license       = "MIT"

  spec.files         = `git ls-files`.split($/)
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.add_dependency "activesupport", ">= 4.0.0"
  spec.add_dependency "activemodel", ">= 4.0.0"
  spec.add_dependency "iso8601", "~> 0.8.6"

  # Drivers
  spec.add_dependency "vimeo", "~> 1.5.3"

  spec.add_development_dependency "bundler", "~> 1.3"
end
