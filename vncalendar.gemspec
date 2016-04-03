# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'vncalendar/version'

Gem::Specification.new do |spec|
  spec.name          = "vncalendar"
  spec.version       = Vncalendar::VERSION
  spec.authors       = ["Man Vuong"]
  spec.email         = ["thanhman.gm@gmail.com"]

  spec.summary       = %q{Vietnamese date converter. A Ruby port of https://github.com/vanng822/vncalendar in Golang}
  spec.description   = %q{Vietnamese date converter. A Ruby port of https://github.com/vanng822/vncalendar in Golang}
  spec.homepage      = "https://github.com/kidlab/vncalendar-ruby"
  spec.license       = "MIT"

  spec.files         = `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }
  spec.bindir        = "exe"
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.add_development_dependency "bundler", "~> 1.11"
  spec.add_development_dependency "rake", "~> 10.0"
  spec.add_development_dependency "minitest", "~> 5.0"
end
