# frozen_string_literal: true
require 'bundler/gem_tasks'

task :default => [:compile, :spec, :rubocop]

require 'rake/extensiontask'
Rake::ExtensionTask.new('attribute_builder') do |ext|
  ext.lib_dir = 'lib/faml'
end

require 'rspec/core/rake_task'
RSpec::Core::RakeTask.new(:spec)

require 'rubocop/rake_task'
RuboCop::RakeTask.new(:rubocop)

task :benchmark => ['benchmark:rendering', 'benchmark:compiling']

namespace :benchmark do
  task :rendering => ['benchmark:rendering:haml', 'benchmark:rendering:attributes', 'benchmark:rendering:slim']
  namespace :rendering do
    desc "Run rendering benchmark with Haml's standard template"
    task :haml do
      faml_spec = Gem::Specification.find_by_name('faml')
      haml_req = faml_spec.dependencies.find { |dep| dep.name == 'haml' }.requirement
      haml_spec = Gem::Specification.find_by_name('haml', haml_req)
      standard_haml_path = File.join(haml_spec.gem_dir, 'test', 'templates', 'standard.haml')
      sh 'ruby', 'benchmark/rendering.rb', standard_haml_path
    end

    desc 'Run rendering benchmark for attribute builder'
    task :attributes do
      sh 'ruby', 'benchmark/rendering.rb', 'benchmark/attribute_builder.haml', 'benchmark/attribute_builder.slim'
    end

    desc "Run slim's rendering benchmark"
    task :slim do
      sh 'ruby', 'benchmark/slim.rb'
    end
  end

  task :compiling => ['benchmark:compiling:haml', 'benchmark:compiling:slim']
  namespace :compiling do
    desc "Run compiling benchmark with Haml's standard template"
    task :haml do
      faml_spec = Gem::Specification.find_by_name('faml')
      haml_req = faml_spec.dependencies.find { |dep| dep.name == 'haml' }.requirement
      haml_spec = Gem::Specification.find_by_name('haml', haml_req)
      standard_haml_path = File.join(haml_spec.gem_dir, 'test', 'templates', 'standard.haml')
      sh 'ruby', 'benchmark/compiling.rb', standard_haml_path
    end

    desc "Run slim's compiling benchmark"
    task :slim do
      sh 'ruby', 'benchmark/compiling.rb', 'benchmark/view.haml', 'benchmark/view.slim'
    end
  end
end
