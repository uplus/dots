#!/usr/bin/env ruby
require_relative './lyrics.rb'

def puts_color(color_num, str)
  puts "\e[38;5;#{color_num}m#{str}\e[00m"
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


class Google
  @@baseurl = 'https://www.google.co.jp/search?q=site:%s+intitle:%s'.freeze
  attr_reader :doc, :cands

  def initialize(site, word)
    @doc = parse(self.class.url(site, word))
    @cands = self.class.parse_cands(@doc)
  end

  def each
    @cands.each
  end

  def size
    @cands.size
  end

  # show candidates and select it interactively
  def select_one
    return @cands[0] if size <= 1

    pager do
      each.with_index do |cand, i|
        print "#{i} "
        yield cand
      end
    end

    num = input_num("[0..#{size-1}]> ")
    @cands[num] rescue nil
  end

  def self.url(site, word)
    @@baseurl % [site, word]
  end

  # return [{title: , url: , desc: }]
  def self.parse_cands(doc)
    doc.css('#search .g').map do |cand|
      title = cand.at_css('.r > a').text
      url   = 'http://'+cand.at_css('.s > div > cite').text
      desc  = cand.at_css('.st').text
      {title: title, url: url, desc: desc}
    end
  end
end

def put_cand(cand)
  unless /^\/item/ =~ URI.parse(cand[:url]).path
    puts_color 184, "%{title}(%{url})\n" % cand
    return
  end

  doc = Kasitime.doc(cand[:url])
  puts_color 111, Kasitime.info_str(doc)
  puts Kasitime.lyrics(doc).gsub("\n", ' ')[0..60], ''
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
    Kasitime.get(url)
  when 1
    doc = Kasitime.doc(url)
    puts Kasitime.save_lyrics(doc)
  when 2
    # TODO show graphics in terminal
    doc = Kasitime.doc(url)
    Kasitime.save_thumbnail(doc)
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


  pagerがきれいな必要ないかも
    Enterで一行づつだしてけばいか
=end
