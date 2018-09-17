#!/usr/bin/env ruby
STDIN.each_cons(ARGV[0].to_i){|s| puts s.join.gsub(/\n/, " ") }
