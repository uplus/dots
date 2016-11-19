#!/usr/bin/env ruby

class String
  def int?
    Integer(self) && true rescue false
  end
end

s = (?A..?Z).map{|c|c*4}.join + (?a..?z).map{|c|c*4}.join

if ARGV[0].int?
  print(s[0...ARGV[0].to_i])
else
  puts s.index ARGV[0]
end
