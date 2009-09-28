require 'spec/rake/spectask'

desc "Run all specs in spec directory"
Spec::Rake::SpecTask.new(:spec) do |t|
  t.spec_opts = ["--format", "progress", "--colour"]
  t.spec_files = FileList['spec/**/*_spec.rb']
end

namespace :spec do
  desc "Print Specdoc for all specs (excluding plugin specs)"
  Spec::Rake::SpecTask.new(:doc) do |t|
    t.spec_opts = ["--format", "specdoc", "--colour", "--dry-run"]
    t.spec_files = FileList['spec/**/*_spec.rb']
  end
end