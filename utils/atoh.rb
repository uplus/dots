#!/usr/bin/env ruby
puts case ARGV.size
when 0
	exit(0)
when 1
  ARGV[0].unpack('H*')[0]
else
	ARGV.map{|c| c.ord.to_s(16)}.join(' ')
end
