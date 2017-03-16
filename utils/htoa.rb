#!/usr/bin/env ruby
case ARGV.size
when 0
	exit(0)
when 1
  p ARGV.pack('H*')
else
	ARGV.map{|hex| p [hex].pack('H*')}
end
