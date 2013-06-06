# -*- encoding: utf-8 -*-
require File.expand_path('../lib/mongoid/preferences/version', __FILE__)

Gem::Specification.new do |gem|
  gem.authors       = ["Mattia Toso"]
  gem.email         = ["mattia@kunerango.com"]
  gem.description   = %q{Preferences with Mongoid}
  gem.summary       = %q{Add preferences hash to Mongoid model}
  gem.homepage      = "https://github.com/matito/mongoid-preferences.git"

  gem.files         = `git ls-files`.split($\)
  gem.executables   = gem.files.grep(%r{^bin/}).map{ |f| File.basename(f) }
  gem.test_files    = gem.files.grep(%r{^(test|spec|features)/})
  gem.name          = "mongoid-preferences"
  gem.require_paths = ["lib"]
  gem.version       = Mongoid::Preferences::VERSION

  gem.add_dependency('mongoid', '~> 3.0.0')

  gem.add_development_dependency('rake', '~> 10.0')
  gem.add_development_dependency('rspec', '~> 2.12')
  gem.add_development_dependency('yard', '~> 0.8')
  gem.add_development_dependency('mongoid-rspec', '~> 1.4.4')
  gem.add_development_dependency('database_cleaner', '~> 1.0')
  gem.add_development_dependency('redcarpet', '~> 2.2')
  gem.add_development_dependency('json', '~> 1.7.7')
end
