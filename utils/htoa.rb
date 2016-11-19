#!/usr/bin/env ruby
case ARGV.size
when 0
	exit(0)
when 1
	ARGV[0].scan(/../).each {|hex| print Integer('0x'+hex).chr }
else
	ARGV.each {|hex| print Integer('0x'+hex).chr, ' ' }
end

puts
