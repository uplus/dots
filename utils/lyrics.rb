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

module Kasitime # {{{
  @@baseurl = 'http://www.kasi-time.com/item-%d.html'.freeze
  @@img_baseurl = 'https://images-na.ssl-images-amazon.com/images/P/%s.jpg'.freeze
  module_function

  def url(number)
    @@baseurl % number
  end

  def doc(arg)
    parse(arg.kind_of?(Integer)? url(arg): arg)
  end

  def title(doc)
    doc.css('.person_list_and_other_contents > h1').text.rstrip
  end

  def lyrics(doc)
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
    category = table.at_css('.other_list').at_css('tr > td').text.gsub(/\s+/, ' ').strip
    person   = table.at_css('.person_list').css('a').text.gsub(/\s+/, ' ').strip
    {title: title, category: category, person: person}
  end

  def info_str(arg)
    hash = arg.kind_of?(Nokogiri::HTML::Document)? info(arg): arg
    "%{title} -- %{category} - %{person}" % hash
  end

  def save_lyrics(doc)
    text = lyrics(doc)
    File.write(title(doc)+'.txt', text)
    text
  end

  def save_thumbnail(doc)
    url     = doc.at_css('.song_image > a')['href']
    id      = URI.parse(url).path.split('/')[3]
    img_url = @@img_baseurl % id
    File.write(title(doc)+'.jpg', open(img_url).read)
  end

  def get(arg)
    doc = doc(arg)
    puts save_lyrics(doc)
    save_thumbnail(doc)
  end
end # }}}


if __FILE__ == $0
  begin
    Kasitime.get(ARGV[0].to_i)
  rescue
    binding.pry
  end
end
