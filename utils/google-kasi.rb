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


module Google
  @@baseurl = 'https://www.google.co.jp/search?q=site:www.kasi-time.com+intitle:%s'.freeze
  module_function

  def url(query)
    @@baseurl % query
  end

  def doc(url_str)
    doc = parse(url_str)
  end

  # return [{title: , url: , description: }]
  def cands(doc)
    doc.css('#search .g').map do |cand|
      title = cand.at_css('.r > a').text
      url = 'http://'+cand.at_css('.s > div > cite').text
      description = cand.at_css('.st').text
      {title: title, url: url, description: description}
    end
  end

  def search(query)
    cands(doc(url(query)))
  end

  # show candidates and select it interactively
  def select(cands, &block)
    return cands[0] if cands.size <= 1

    pager do
      cands.each_with_index do |cand, i|
        print "#{i} "
        block.call cand
      end
    end

    num = input_num("[0..#{cands.size-1}]> ")
    cands[num] rescue nil
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
  cands = Google.search(ARGV.shift)
  cand = Google.select(cands, &method(:put_cand))
  exit unless cand

  p cand
  url = cand[:url]

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

