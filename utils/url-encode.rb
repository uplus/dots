#!/usr/bin/env ruby
require 'erb'

def url_encode(str)
  ERB::Util.url_encode(str)
end

if File.pipe?(STDIN)
  puts url_encode(STDIN.readlines.join)
elsif not ARGV.empty?
  puts url_encode(ARGV.join(' '))
end
