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