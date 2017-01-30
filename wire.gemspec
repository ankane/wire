# coding: utf-8
lib = File.expand_path("../lib", __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require "wire/version"

Gem::Specification.new do |spec|
  spec.name          = "wire"
  spec.version       = Wire::VERSION
  spec.authors       = ["Andrew Kane"]
  spec.email         = ["andrew@chartkick.com"]

  spec.summary       = "A pub-sub framework built on Kafka"
  spec.homepage      = "https://github.com/ankane/wire"
  spec.license       = "MIT"

  # Prevent pushing this gem to RubyGems.org. To allow pushes either set the 'allowed_push_host'
  # to allow pushing to a single host or delete this section to allow pushing to any host.
  if spec.respond_to?(:metadata)
    spec.metadata["allowed_push_host"] = "TODO: Set to 'http://mygemserver.com'"
  else
    raise "RubyGems 2.0 or newer is required to protect against " \
      "public gem pushes."
  end

  spec.files = `git ls-files -z`.split("\x0").reject do |f|
    f.match(%r{^(test|spec|features)/})
  end
  spec.bindir        = "exe"
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.add_dependency "ruby-kafka"
  spec.add_dependency "errbase"

  spec.add_development_dependency "bundler"
  spec.add_development_dependency "rake"
  spec.add_development_dependency "minitest"
  spec.add_development_dependency "activerecord"
  spec.add_development_dependency "sqlite3"
  spec.add_development_dependency "msgpack"
end
