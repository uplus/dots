#!/usr/bin/env ruby
case ARGV.size
when 0
	exit(0)
when 1
  print '0x'
  ARGV[0].each_char {|c| print c.ord.to_s(16) }
else
  print '0x'
	ARGV.each {|c| print c.ord.to_s(16), ' ' }
end

puts
