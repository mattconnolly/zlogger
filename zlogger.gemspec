# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'zlogger/version'

Gem::Specification.new do |spec|
  spec.name          = "zlogger"
  spec.version       = Zlogger::VERSION
  spec.authors       = ["Matt Connolly"]
  spec.email         = ["matt.connolly@me.com"]
  spec.summary       = %q{A distributed logging daemon.}
  spec.description   = %q{This gem provides a daemon that reads log messages from a ZeroMQ socket. Messages are formatted and output to STDOUT. }
  spec.homepage      = ""
  spec.license       = "MIT"

  spec.files         = `git ls-files -z`.split("\x0")
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.add_runtime_dependency "rbczmq", "~> 1.7"
  spec.add_development_dependency "bundler", "~> 1.6"
  spec.add_development_dependency "rake"
  spec.add_development_dependency "rspec", "~> 2.14"
  spec.add_development_dependency "timecop", "~> 0.7"
end
