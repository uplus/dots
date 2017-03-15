#!/usr/bin/env ruby

class String
  def int?
    Integer(self) && true rescue false
  end
end

s = ((?A..?Z).to_a+(?a..?z).to_a).map{|c| c*4}.join

newline = ARGV.delete('-n')? "\n": ''

if ARGV[0].int?
  print(s[0...ARGV[0].to_i] + newline)
else
  puts s.index ARGV[0]
end
