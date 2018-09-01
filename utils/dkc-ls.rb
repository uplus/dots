#!/usr/bin/env ruby
require 'yaml'

filepath = ARGV.first || 'docker-compose.yml'
puts YAML.load(File.read(filepath))['services'].keys
