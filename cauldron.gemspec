# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'cauldron/version'

Gem::Specification.new do |s|
  s.name = %q{cauldron}
  s.version = Cauldron::VERSION
  s.authors = ["Warren Sangster"]
  #s.default_executable = %q{cauldron}
  s.description = %q{Cauldron generates a methd from a number of examples that describe the input and the expected output.  It is still at a very early stage of development right now so you're unlikely to get much practical use out of it.}
  s.email = %q{warrensangster@yahoo.com}
  #s.executables = ["cauldron"]
  s.files         = `git ls-files`.split($/)
  s.executables   = s.files.grep(%r{^bin/}) { |f| File.basename(f) }
  s.test_files    = s.files.grep(%r{^(test|spec|features)/})
  s.require_paths = ["lib"]  
  s.homepage = %q{https://github.com/theinbetweens/cauldron}
  s.licenses = ["MIT"]  
  s.rubygems_version = %q{1.4.0}
  s.summary = %q{Generate simple ruby methods from the input(s) and expected output}

  s.add_development_dependency "bundler", "~> 1.3"
  s.add_development_dependency "rake"
  s.add_runtime_dependency "ruby2ruby", "~> 1.2.5"
end

