# encoding: utf-8

require 'rubygems'
require 'bundler'
Bundler.setup
Bundler::GemHelper.install_tasks

#require 'cucumber/rake/task'
#require "bundler/gem_tasks"
#require 'cucumber'


require 'rubygems'
require 'cucumber'
require 'cucumber/rake/task'

# Copied - https://github.com/cucumber/aruba/blob/master/Rakefile
Cucumber::Rake::Task.new do |t|
  t.cucumber_opts = ""
  # t.cucumber_opts = "--format Cucumber::Pro --out cucumber-pro.log" if ENV['CUCUMBER_PRO_TOKEN']
  t.cucumber_opts << "--format pretty"
end

# https://www.relishapp.com/rspec/rspec-core/docs/command-line/rake-task
begin
  require 'rspec/core/rake_task'

  RSpec::Core::RakeTask.new(:spec)

  task :default => :spec
rescue LoadError
  # no rspec available
end