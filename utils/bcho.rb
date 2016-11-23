#!/usr/bin/env ruby

class String
  def int?
    Integer(self)
  rescue # special
    Integer('0x'+self)
    true
  rescue
    false
  end

  def to_bin
    self.to_i(16).chr
  end

  def hex_strip
    self.dup.hex_strip!
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
  hex_str = hex_align(hex_str)
  return hex_str.scan(/../).map(&:to_bin).reverse.join
end

ARGV.map do |str|
  if str.int?
    print to_little(str)
  else
    str += "\0" if str !~ /\0$/
    print str
  end
end
