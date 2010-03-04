# -*- encoding: utf-8 -*-

Gem::Specification.new do |s|
  s.name = %q{authoritah}
  s.version = "0.1.2"

  s.authors = ["Steven Mohapi-Banks"]
  s.date = %q{2010-03-04}
  s.email = %q{steven.mohapibanks@me.com}
  s.extra_rdoc_files = [
    "LICENSE",
     "README.rdoc"
  ]
  s.files = [
    'init.rb',
    'lib/authoritah.rb'
  ]
  s.homepage = %q{http://github.com/indmill/authoritah}
  s.rdoc_options = ["--charset=UTF-8"]
  s.require_paths = ["lib"]
  s.rubygems_version = %q{1.3.4}
  s.summary = %q{A really simple authorization plugin for Rails.}
  s.description = %q{A description of a really simple authorization plugin for Rails.}
  s.test_files = [
    'spec/authoritah_spec.rb',
    'spec/spec_helper.rb',
    'spec/railsenv',
    'spec/railsenv/app/controllers/application.rb',
    'spec/railsenv/config/boot.rb',
    'spec/railsenv/config/database.yml',
    'spec/railsenv/config/environment.rb',
    'spec/railsenv/config/environments/development.rb',
    'spec/railsenv/config/environments/test.rb',
    'spec/railsenv/config/initializers/backtrace_silencers.rb',
    'spec/railsenv/config/initializers/inflections.rb',
    'spec/railsenv/config/initializers/mime_types.rb',
    'spec/railsenv/config/initializers/new_rails_defaults.rb',
    'spec/railsenv/config/initializers/session_store.rb',
    'spec/railsenv/config/locales/en.yml',
    'spec/railsenv/config/routes.rb'
  ]
  s.add_development_dependency('rspec', '>= 1.2.9')
  s.add_development_dependency('rspec-rails', '>= 1.2.9')
  s.add_development_dependency('mocha', '>= 0.9.8')
end
