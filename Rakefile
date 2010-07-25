require 'rake'
require 'spec/rake/spectask'
require 'rake/rdoctask'
require 'yard'

task :default => :spec

desc "Run specs"
Spec::Rake::SpecTask.new do |t|
  t.spec_files = FileList['spec/**/*_spec.rb']
  t.spec_opts = %w(-fs --color)
end

desc 'Generate documentation for the enum_helper plugin.'
Rake::RDocTask.new(:rdoc) do |rdoc|
  rdoc.rdoc_dir = 'rdoc'
  rdoc.title    = 'EnumHelper'
  rdoc.options << '--line-numbers' << '--inline-source'
  rdoc.rdoc_files.include('README.rdoc')
  rdoc.rdoc_files.include('lib/**/*.rb')
end

YARD::Rake::YardocTask.new do |t|
  t.files   = ['lib/enum_helper.rb']
  t.options = [
    '--hide-void-return',
    '--no-private',
    "--title=Steve Downey's Enum Helper",
  ]
end