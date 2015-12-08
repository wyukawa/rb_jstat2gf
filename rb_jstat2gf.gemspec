# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'rb_jstat2gf/version'

Gem::Specification.new do |spec|
  spec.name          = "rb_jstat2gf"
  spec.version       = RbJstat2gf::VERSION
  spec.authors       = ["wyukawa"]
  spec.email         = ["wyukawa@gmail.com"]
  spec.summary       = %q{It is a Ruby clone of jstat2gf}
  spec.description   = %q{post jstat metrics to GrowthForecast}
  spec.homepage      = "https://github.com/wyukawa/rb_jstat2gf"
  spec.license       = "MIT"

  spec.files         = `git ls-files -z`.split("\x0")
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.add_development_dependency "bundler", "~> 1.7"
  spec.add_development_dependency "rake", "~> 10.0"
end
