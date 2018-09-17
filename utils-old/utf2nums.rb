#!/usr/bin/env ruby

if ARGV.empty?
  puts '[-h] STRINGS'
  exit
end

if ARGV.first == '-h'
  ARGV.shift
  is_hex = true
end

nums = ARGV.join.unpack("U*")
nums.map!{|n| n.to_s(16) } if is_hex
puts nums.join(' ')
