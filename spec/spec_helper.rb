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
require 'pry'

def config_data
  yaml_path = File.join(ActivePublicResources.root, 'active_public_resources_config.yml')
  unless File.exist? yaml_path
    yaml_path = File.join(ActivePublicResources.root, 'active_public_resources_config.yml.example')
  end
  config = YAML::load(File.read(yaml_path))
  ActivePublicResources.symbolize_keys(config)
end

VCR.configure do |c|
  c.cassette_library_dir = File.join(ActivePublicResources.root, "spec", "vcr")
  config_data.each do |driver_name, options|
    (options || {}).each do |k,v|
      c.filter_sensitive_data("#{driver_name.upcase}_#{k.upcase}") { v }
    end
  end
  c.allow_http_connections_when_no_cassette = true
  c.hook_into :webmock
end

RSpec.configure do |config|
  config.filter_run_excluding :live_api => true
  config.treat_symbols_as_metadata_keys_with_true_values = true
  config.around(:each, :vcr) do |example|
    name = example.metadata[:full_description].split(/\s+/, 2).join("/").underscore.gsub(/[^\w\/]+/, "_")
    options = {}
    options[:record] = example.metadata[:record] if example.metadata[:record].present?
    options[:match_requests_on] = example.metadata[:match_requests_on] if example.metadata[:match_requests_on].present?
    VCR.use_cassette(name, options) { example.call }
  end
end
