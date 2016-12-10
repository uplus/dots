#!/usr/bin/env ruby
require 'pry'

require_relative './lyrics.rb'

#-------------------------------------------------------------------------------------------------------------------------------------------------------------------

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

  def cands(doc)
    doc.css('#search .g').map do |cand|
      title = cand.at_css('.r > a').text
      url = 'http://'+cand.at_css('cite').text
      description = cand.at_css('span').text
      {title: title, url: url, description: description}
    end
  end

  def select(cands)
    case cands.size
    when 0
      nil
    when 1
      cands[0]
    else
      pager do
        cands.each_with_index do |cand, i|
          print "#{i} "
          yield cand
        end
      end

      num = input_num("[0..#{cands.size-1}]> ")
      cands[num] rescue nil
    end
  end

  def search(query)
    cands(doc(url(query)))
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
  cands = Google.search('ライオン')
  cand = Google.select(cands, &method(:put_cand))

  # select  [lyrics[save, out], thumbnail, all]
  puts Kasitime.lyrics(parse(cand[:url]))

rescue => e
  puts "Error"
  p e, e.backtrace, e.message
ensure
  binding.pry
end

