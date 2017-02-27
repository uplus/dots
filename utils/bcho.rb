#!/usr/bin/env ruby

# usage:
#   #little endian binary(use all numeric as a hex)
#   bcho 0x1234 #=> 3412
#   bcho 1234   #=> 3412
#
#   #string
#   bcho ls 0  #=> 6c73 00
#   bcho ls\0  #=> 6c73 30

class String
  def int?
    Integer(self) rescue return false
  end

  def to_bin
    self.to_i(16).chr
  end

  def hex_strip!
    self.sub!(/^0x|h$/, '')
  end
end

def hex_align(hex_str)
  hex_str.hex_strip!
  hex_str.insert(0, '0') if hex_str.size.odd?
  hex_str
end

def to_little(hex_str)
  hex_str = hex_align(hex_str.dup)
  return hex_str.scan(/../).map(&:to_bin).reverse.join
end

if __FILE__ == $0
  ARGV.map do |str|
    if str.int?
      print to_little(str)
    else
      print str
    end
  end
end

