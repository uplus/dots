#!/usr/bin/env ruby

class String
  def int?
    Integer(self) && true rescue false
  end
end

def hex_strip(hex_str)
  hex_str.sub(/^0x|h$/, '')
end

def hex_align(hex_str)
  hex_str.insert(0, '0') if hex_str.size.odd?
  hex_str
end

def little(hex_str)
  hex_str = hex_strip(hex_str)
  hex_str = hex_align(hex_str)
  return hex_str.scan(/../).map{|s| s.to_i(16).chr}.reverse.join
end

ARGV.map do |str|
  if str.int?
    print little(str)
  else
    str += "\0" if str !~ /\0$/
    print str
  end
end
