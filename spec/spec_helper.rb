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

RSpec.configure do |config|

end