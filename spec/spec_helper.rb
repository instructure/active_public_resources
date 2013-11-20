#!/usr/bin/env ruby
$:.unshift File.expand_path('../../lib', __FILE__)

begin
  require 'rubygems'
  require 'bundler'
  Bundler.setup
rescue LoadError => e
  puts "Error loading bundler (#{e.message}): \"gem install bundler\" for bundler support."
end

require 'active_public_resources'
require 'vcr'

def config_data
  yaml_path = File.join(ActivePublicResources.root, 'active_public_resources_config.yml')
  config = YAML::load(File.read(yaml_path))
  config.inject({}){|memo,(k,v)| memo[k.to_sym] = v; memo}
  config
end

VCR.configure do |c|
  c.cassette_library_dir = File.join(ActivePublicResources.root, "spec", "vcr")
  config_data.each do |driver_name, options|
    options.each do |k,v|
      c.filter_sensitive_data("#{driver_name.upcase}_#{k.upcase}") { v }
    end
  end
  c.hook_into :webmock
end

RSpec.configure do |config|
  config.filter_run_excluding :live_api => true
end
