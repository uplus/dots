#!/usr/bin/env ruby
puts case ARGV.size
when 0
	exit(0)
when 1
  ARGV.pack('H*')
else
	ARGV.map{|hex| [hex].pack('H*')}.join(' ')
end
