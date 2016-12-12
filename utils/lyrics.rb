#!/usr/bin/env ruby
require 'open-uri'
require 'fileutils'
require 'base64'
require 'nokogiri'
require 'pry'

# one instance one directory
class Cache # {{{
  @@base_cache_dir = File.join(Dir.home, '.cache').freeze
  attr_reader :cache_dir

  def initialize(dir_name)
    @cache_dir = File.join(@@base_cache_dir, dir_name).freeze
    FileUtils.mkdir_p(@cache_dir)
  end

  def encode(name)
    Base64.urlsafe_encode64(name)
  end

  def path(name)
    File.join(@cache_dir, encode(name))
  end

  # return Time
  def date(name)
    File.stat(path(name)).mtime rescue nil
  end

  def exist?(name)
    File.exist?(path(name))
  end

  def save(name, str)
    File.write(path(name), str, encoding: 'utf-8')
    str
  end

  def load(name)
    File.read(path(name), encoding: 'utf-8') rescue nil
  end

  def remove(name)
    FileUtils.rm(path(name))
  end

  def clear
    FileUtils.rm_r(@cache_dir)
  end
end # }}}

# url ベースでキャッシュを保存
cache = Cache.new('kasitime')

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
