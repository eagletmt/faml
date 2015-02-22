require 'bundler/gem_tasks'

task :default => [:compile, :spec]

require 'rake/extensiontask'
Rake::ExtensionTask.new('attribute_builder') do |ext|
  ext.lib_dir = 'lib/fast_haml'
end

require 'rspec/core/rake_task'
RSpec::Core::RakeTask.new(:spec)
