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
  s.rubyforge_project = %q{authoritah}
  s.rubygems_version = %q{1.3.4}
  s.summary = %q{A really simple authorization plugin for Rails.}
  s.test_files = [
    'spec/authoritah_spec.rb',
    'spec/spec_helper.rb'
  ]
end
