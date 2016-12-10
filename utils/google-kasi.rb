#!/usr/bin/env ruby
require 'open-uri'
require 'nokogiri'
require 'tty-pager'
require 'pry'

def parse(url_str, opt={})
  charset = nil
  opt[:redirect] = false
  html = open(URI.encode(url_str), opt) do |f|
    charset = f.charset
    f.read
  end
  Nokogiri::HTML.parse(html, nil, charset)

rescue OpenURI::HTTPRedirect => e
  # for http -> https redirect
  puts 'redirect: %s -> %s' % [url_str, e.uri.to_s]
  url_str = e.uri.to_s
  retry
end

def lyrics(doc)
  js_text = doc.css('.center > script')[0].text
  html_text = js_text.split("\n").grep(/^\s*var\s*lyrics\s*=/)[0]
  text = Nokogiri::HTML.parse(html_text).xpath('//p').inner_html.gsub('<br>', "\n")
  text.sub!(/\Avar\s*lyrics\s*=\s*'/, '')
  text.sub!(/';\z/, '')
  text
end


#----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

def info(doc)
  table    = doc.at_css('.person_list_and_other_contents')
  title    = table.at_css('h1').text.strip
  person   = table.at_css('.person_list').css('a').text.gsub(/\s+/, ' ').strip
  category = table.at_css('.other_list').at_css('tr > td').text.gsub(/\s+/, ' ').strip
  "#{title} -- #{category} - #{person}"
end

def puts_color(color_num, str)
  puts "\e[#{color_num}m#{str}\e[0m"
end

def is_item?(url_str)
  uri = URI.parse(url_str)
  /^\/item/ =~ uri.path
end

def puts_g(child)
  cite = 'http://'+child.at_css('cite').text

  unless is_item?(cite)
    title = child.at_css('.r > a').text
    puts_color 33, "%s(%s)\n" % [title, cite]
    return nil
  end

  doc = parse(cite)
  puts_color 95, info(doc)
  puts lyrics(doc).gsub("\n", ' ')[0..60], ''
  cite
end

def pager
  $stdout = out = StringIO.new
  return yield
ensure
  $stdout = STDOUT
  opt='--RAW-CONTROL-CHARS --quit-if-one-screen --no-init'
  IO.popen(['less', opt], 'w'){|f| f.puts out.string }
end


begin

url = 'https://www.google.co.jp/search?q=site:www.kasi-time.com+intitle:%s' % 'ライオン'
doc = parse(url)
g = doc.css('#search .g')

cands = pager do
  g.map.with_index do |child, i|
    print "#{i} "
    puts_g child
  end
end


print "number>> "
num = gets.to_i

puts cands[num]
puts lyrics(parse(cands[num]))

binding.pry
rescue => e
  puts "Error"
  p e
  binding.pry
end
# description = g[0].css('span').text
