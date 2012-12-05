# -*- encoding: utf-8 -*-
require File.expand_path('../lib/codice_fiscale/version', __FILE__)

Gem::Specification.new do |gem|
  gem.authors       = ["topac"]
  gem.email         = ["topac@users.noreply.github.com"]
  gem.description   = %q{Calculate the italian fiscal code}
  gem.summary       = %q{Calculate the italian fiscal code}
  gem.homepage      = "https://github.com/topac/codice_fiscale"
  gem.platform      = Gem::Platform::RUBY

  gem.files         = `git ls-files`.split($\)
  gem.executables   = gem.files.grep(%r{^bin/}).map{ |f| File.basename(f) }
  gem.test_files    = gem.files.grep(%r{^(test|spec|features)/})
  gem.name          = "codice-fiscale"
  gem.require_paths = ["lib"]
  gem.version       = CodiceFiscale::VERSION

  gem.add_development_dependency 'rspec'
  gem.add_development_dependency 'guard-rspec'
  gem.add_development_dependency 'rb-fsevent', '~> 0.9.1'
  # The growl app must be separately downloaded and installed
  gem.add_development_dependency 'growl'

  gem.add_dependency 'active_support'
end