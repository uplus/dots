#!/usr/bin/env ruby
require_relative './lyrics.rb'

def color_str(color_num, str)
  "\e[38;5;#{color_num}m#{str}\e[00m"
end

def pager
  $stdout = out = StringIO.new
  return yield
ensure
  $stdout = STDOUT
  opt='--RAW-CONTROL-CHARS --quit-if-one-screen --no-init'
  IO.popen(['less', opt], 'w'){|f| f.puts out.string }
end

def input_num(str)
  print str
  gets&.to_i
rescue Interrupt
  nil
end


class Google < Scraping
  @@baseurl = 'https://www.google.co.jp/search?q=site:%s+intitle:%s'.freeze

  def initialize(site, word)
    super(self.class.url(site, word))
  end

  def each
    cands.each
  end

  def size
    cands.size
  end

  # show candidates and select it interactively
  def select_one
    return cands[0] if size <= 1

    pager do
      each.with_index do |cand, i|
        print "#{i} "
        yield cand
      end
    end

    num = input_num("[0..#{size-1}]> ")
    cands[num] rescue nil
  end

  # return [{title: , url: , desc: }]
  def cands
    @cands ||= doc.css('#search .g').map do |cand|
      title = cand.at_css('.r > a').text
      url   = 'http://'+cand.at_css('.s > div > cite').text
      desc  = cand.at_css('.st').text
      {title: title, url: url, desc: desc}
    end
  end

  def self.url(site, word)
    @@baseurl % [site, word]
  end
end

#TODO キャッシュが大量に増えるしむだ?
def put_cand(cand)
  unless /^\/item/ =~ URI.parse(cand[:url]).path
    puts color_str(184, "%{title}(%{url})\n" % cand)
    return
  end

  kasi = Kasitime.new(cand[:url])
  puts color_str(111, kasi.info_str)
  puts kasi.lyrics.gsub("\n", ' ')[0..60], ''
end

begin
  res = Google.new('www.kasi-time.com', ARGV.shift)
  cand = res.select_one &method(:put_cand)
  exit unless cand

  p cand
  url = cand[:url]

  binding.pry

  case input_num('[0:all, 1:lyrics, 2:thumbnail, other: quit]> ')
  when 0
    kasi = Kasitime.new(url)
    puts kasi.save_lyrics
    kasi.save_thumbnail
  when 1
    kasi = Kasitime.new(url)
    puts kasi.save_lyrics
  when 2
    # TODO show graphics in terminal
    kasi = Kasitime.new(url)
    kasi.save_thumbnail
  else
    exit
  end
rescue => e
  puts "Error"
  puts e, e.message, e.backtrace
  binding.pry
end

=begin TODO
option
  quick-mode: Show raw cands
  images:     Cannot use pager
  length:     Length of part of lyrics
  search-num: 表示数

  cache

  pagerがきれいな必要ないかも
    Enterで一行づつだしてけばいか
=end
