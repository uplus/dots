# encoding: ASCII-8BIT
require 'pry'
require 'pp'
require 'socket'
require 'pwnlib'
require 'fsalib'
require 'lazyeval'

class String
  def to_ihex
    to_i 16
  end

  def to_bin
    unpack('H*').first.to_ihex
  end

  def scan_num(num)
    each_char.each_slice(num).map(&:join)
  end

  # num文字目以降を返す
  def from(num)
    self[num..-1]
  end

  alias hex to_ihex
end

class Integer
  def to_shex
    to_s 16
  end

  alias hex to_shex
end

class Solver < PwnTube
  def set_nodelay
    socket.setsockopt(Socket::IPPROTO_TCP, Socket::TCP_NODELAY, 1)
  end

  def gets(num=nil, timeout=5)
    if num
      num.times.map{ recv_until("\n", timeout)}
    else
      recv_until("\n", timeout)
    end
  end

  def recvnb(byte=0xffff)
    socket.read_nonblock(byte) rescue nil
  end

  def io(str)
    puts str
    gets + recvnb.to_s
  end

  def interact(terminate_string = "exit")
    $>.puts recvnb(1024*5)
    $>.puts 'interactive'
    $>.puts io('id')

    socket.flush
    loop do
      $>.print '>> '
      s = $stdin.gets
      if !s || s.chomp == terminate_string
        $>.puts 'end interactive mode'
        break
      end
      socket.puts(s)
      sleep(0.1)
      $>.puts recvnb(1024*5)
    end
  end

  alias :puts :sendline
  alias :read :recv
  alias :readnb :recvnb
  alias :r :recvnb
  alias :p :puts
  alias :i :interact
end

def pack(hex_str)
  [hex_str].pack('V')
end

def unpack(hex_str)
  hex_str.unpack('V')[0]
end

def chpat(num)
  $alphabets ||= ((?A..?Z).to_a+(?a..?z).to_a).map{|c| c*4}.join
  $alphabets[0, num]
end

def fsa(pos, padding, startlen, dest_value_hash)
  f = FSA.new
  dest_value_hash.each{|k,v| f[k] = v}
  f.payload(pos, padding, startlen)
end

# deprecated
def fsa_word(pos, dest_addr, value, padding=0, startlen=0)
  fsa(pos,padding, startlen, dest_addr => value)
  # FSA.new.tap{|f| f[dest_addr] = value}.payload(pos, padding, startlen)

  # # 下位から書き込むためにsplit&reverse
  # data    = value.to_shex.reverse.scan(/.{1,4}/).map{|s| s.reverse.to_ihex}
  # stage   = data.size # 分割数
  # dests   = stage.times.map{|i| pack(dest_addr+0x2*i)}
  # num     = dests.map(&:size).inject(&:+)
  # nums    = data.unshift(num).each_cons(2).map{|val,num| (num-val)%0x10000}
  # payload = nums.map.with_index{|v,i| "%#{v}c%#{pos+i}$hn"}.inject(&:+)
  # dests.inject(&:+) + payload
end

def fsa2split(pos, dest_addr, str, padding=0, startlen=0)
  nums = str.scan(/.{1,2}/).map{|s| s.reverse.to_bin}
  nums.map.with_index do |n,i|
    FSA.new.tap{|f| f[dest_addr+2*i] = n}.payload(pos, padding, startlen)
  end.tap{|s| p s}

  # nums = str.scan(/.{1,2}/).map{|s| s.reverse.to_bin}
  # nums.map.with_index do |n,i|
  #   padding = (n-pack(dest_addr).size-pre.size) % 0x10000
  #   "#{pre}#{pack(dest_addr+2*i)}%#{padding}c%#{pos}$hn"
  # end
end
