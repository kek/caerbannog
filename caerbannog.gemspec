# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'caerbannog/version'

Gem::Specification.new do |spec|
  spec.name          = "caerbannog"
  spec.version       = Caerbannog::VERSION
  spec.authors = [
    "Dennis Rogenius",
    "Karl Eklund",
    "Kristoffer Roupé",
    "Lennart Fridén",
    "Martin Svalin",
    "Mikael Amborn",
    "Victoria Wagman"
  ]
  spec.email = [
    "dennis@magplus.com",
    "karl@magplus.com",
    "kristoffer@maglus.com",
    "lennart@magplus.com",
    "martin@magplus.com",
    "mikael.amborn@magplus.com",
    "victoria@magplus.com"
  ]

  spec.summary       = %q{Library for handling messages}
  spec.description   = %q{Implements a database buffer and workers for sending events to RabbitMQ}
  spec.homepage      = "https://github.com/magplus/caerbannog"
  spec.license       = "MIT"

  spec.files         = `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.add_development_dependency "bundler", "~> 1.8"
  spec.add_development_dependency "rake", "~> 10.0"
  spec.add_development_dependency "mocha"
  spec.add_development_dependency "rspec"

  spec.add_dependency "bunny"
end
