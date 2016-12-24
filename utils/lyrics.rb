#!/usr/bin/env ruby
require 'open-uri'
require 'fileutils'
require 'base64'
require 'nokogiri'
require 'pry'

# module OpenURI
#   def OpenURI.redirectable?(uri, redirect_uri)
#     true
#   end
# end

# one instance one directory
class Cache # {{{
  @@base_cache_dir = File.join(Dir.home, '.cache').freeze
  @@app_dir = ''
  attr_reader :cache_dir

  def self.app_dir
    @@app_dir
  end

  def self.app_dir=(dir)
    @@app_dir = dir
  end

  def initialize(dir_name)
    @cache_dir = File.join(@@base_cache_dir, @@app_dir, dir_name).freeze
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
    File.write(path(name), str)
    str
  end

  def load(name)
    File.read(path(name)) rescue nil
  end

  def remove(name)
    FileUtils.rm(path(name))
  end

  def clear
    FileUtils.rm_r(@cache_dir)
  end
end # }}}

# auto cache
class Scraping # {{{
  @@user_agent = 'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_10_5) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/XXXXXX'.freeze
  attr_reader :doc

  def initialize(url_str, opt={})
    @doc = get_doc(url_str, opt)
  end

  def cache
    @cache ||= Cache.new(self.class.to_s)
  end

  # auto redirect http -> https
  def open_auto_redirect(url_str, opt={}, &block)
    opt[:redirect] = false
    open(URI.encode(url_str), opt, &block)
  rescue OpenURI::HTTPRedirect => e
    puts 'redirect: %s -> %s' % [url_str, e.uri.to_s]
    url_str = e.uri.to_s
    retry
  end

  # &block or #read
  def open_caching(url_str, opt={}, &block)
    return cache.load(url_str) if cache.exist?(url_str)
    data = open_auto_redirect(url_str, opt, &(block_given? ? block : :read))
    cache.save(url_str, data)
  end

  def get_html(url_str, opt={})
    # convert anything to utf-8
    open_caching(url_str, opt){|f| f.read.encode!('utf-8', f.charset)}
  end

  def get_doc(url_str, opt={})
    Nokogiri::HTML.parse(get_html(url_str, opt))
  end
end # }}}

class Kasitime < Scraping # {{{
  @@base_url = 'http://www.kasi-time.com/item-%d.html'.freeze
  @@base_img_url = 'https://images-na.ssl-images-amazon.com/images/P/%s.jpg'.freeze

  # Take number or full-url
  def initialize(arg)
    super(arg.kind_of?(Integer)? self.class.url(arg): arg)
  end

  def self.url(number)
    @@base_url % number
  end

  def info
    return @info if @info
    table    = doc.at_css('.person_list_and_other_contents')
    @info = {
      title:    table.at_css('h1').text.strip,
      category: table.at_css('.other_list').at_css('tr > td').text.gsub(/\s+/, ' ').strip,
      person:   table.at_css('.person_list').css('a').text.gsub(/\s+/, ' ').strip
    }
  end

  def info_str
    "%{title} -- %{category} - %{person}" % info
  end

  def lyrics
    return @lyrics if @lyrics
    html_text = doc.at_css('.center > script').child.text[/(?<=var lyrics = ').[^']*(?<!;'$)/]
    elem = Nokogiri::HTML.parse(html_text).at_xpath('//p')
    elem.search('br').each{|br| br.replace("\n")}
    @lyrics = elem.text.sub(/\s*\z/, "\n")
  end

  def save_lyrics
    File.write(info[:title] +'.txt', lyrics)
    lyrics
  end

  def save_thumbnail
    url     = doc.at_css('.song_image > a')['href']
    id      = URI.parse(url).path.split('/')[3]
    img_url = @@base_img_url % id
    File.write(info[:title] +'.jpg', open_caching(img_url))
  end
end # }}}


# TODO: tmp
Cache.app_dir = 'lyrics'

if __FILE__ == $0
  begin
    kasi = Kasitime.new(ARGV[0].to_i)
    puts kasi.save_lyrics
    kasi.save_thumbnail
  rescue
    puts $!.message
    puts $!.backtrace
    binding.pry
  end
end
