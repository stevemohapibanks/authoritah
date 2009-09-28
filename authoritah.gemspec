# -*- encoding: utf-8 -*-

Gem::Specification.new do |s|
  s.name = %q{authoritah}
  s.version = "0.0.1"

  s.authors = ["Steven Mohapi-Banks"]
  s.date = %q{2009-09-24}
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
  s.description = %q{A really simple authorization plugin for Rails.}
  s.test_files = [
    'spec/authoritah_spec.rb',
    'spec/spec_helper.rb',
    'spec/rails_env',
    'spec/rails_env/app/controllers/application.rb',
    'spec/rails_env/config/boot.rb',
    'spec/rails_env/config/database.yml',
    'spec/rails_env/config/environment.rb',
    'spec/rails_env/config/environments/cucumber.rb',
    'spec/rails_env/config/environments/development.rb',
    'spec/rails_env/config/environments/production.rb',
    'spec/rails_env/config/environments/test.rb',
    'spec/rails_env/config/initializers/backtrace_silencers.rb',
    'spec/rails_env/config/initializers/inflection.rb',
    'spec/rails_env/config/initializers/mime_types.rb',
    'spec/rails_env/config/initializers/new_rails_defaults.rb',
    'spec/rails_env/config/initializers/session_store.rb',
    'spec/rails_env/config/locales/en.rb',
    'spec/rails_env/config/routes.rb'
  ]
end
