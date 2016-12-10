#!/usr/bin/env ruby
require 'open-uri'
require 'nokogiri'
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


  def lyrics(doc) # TODO delete
    js_text = doc.css('.center > script')[0].text
    html_text = js_text.split("\n").grep(/^\s*var\s*lyrics\s*=/)[0]
    text = Nokogiri::HTML.parse(html_text).xpath('//p').inner_html.gsub('<br>', "\n")
    text.sub!(/\Avar\s*lyrics\s*=\s*'/, '')
    text.sub!(/';\z/, '')
    text
  end

def info(doc)
  table    = doc.at_css('.person_list_and_other_contents')
  title    = table.at_css('h1').text.strip
  person   = table.at_css('.person_list').css('a').text.gsub(/\s+/, ' ').strip
  category = table.at_css('.other_list').at_css('tr > td').text.gsub(/\s+/, ' ').strip
  "#{title} -- #{category} - #{person}"
end

# site:www.kasi-time.com intitle:ノーポイッ
url = 'https://www.google.co.jp/search?q=site:www.kasi-time.com+intitle:%s' % 'ライオン'
doc = parse(url)

search = doc.css('#search')
g = search.css('.g')

def puts_color(color_num, str)
  print "\e[%dm" % color_num
  puts str
  print "\e[0m"
end

def is_item?(url_str)
  uri = URI.parse(url_str)
  /^\/item/ =~ uri.path
end

begin

g.each do |child|
  cite = 'http://'+child.at_css('cite').text

  unless is_item?(cite)
    title = child.at_css('.r > a').text
    puts_color 33, '%s(%s)' % [title, cite]
    next
  end

  doc = parse(cite)
  puts_color 95, info(doc)
  puts lyrics(doc).gsub("\n", ' ')[0..60]
  puts
end


binding.pry
rescue => e
  p e
  binding.pry
end

# title = g[0].css('.r > a').text
# title = g[0].at_css('.r > a').text
# cite = g[0].css('cite').text
# description = g[0].css('span').text
