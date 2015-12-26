require 'bundler/gem_tasks'
require 'rspec/core/rake_task'
require 'rake/extensiontask'

RSpec::Core::RakeTask.new(:spec)

Rake::ExtensionTask.new('postfix_status_line_core') do |ext|
  ext.ext_dir = 'ext'
end

task :default => [:spec]
task :spec => [:compile]
task :compile => [:clean]
