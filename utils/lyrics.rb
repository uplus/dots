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

module Kasitime
  module_function

  def doc(number)
    parse('http://www.kasi-time.com/item-%d.html' % number)
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

  def save_lyrics(doc)
    File.write(title(doc)+'.txt', lyrics(doc))
  end

  def save_thumbnail(doc)
    amazon_url = doc.css('.song_image > a')[0]['href']
    Amazon.save_img(title(doc), amazon_url)
  end

  def get(number)
    doc = doc(number)
    save_lyrics(doc)
    save_thumbnail(doc)
  end
end

module Amazon
  module_function

  def doc(url_str)
    opt = { 'User-Agent' => 'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_10_5) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/XXXXXXXXXXXXX Safari/XXXXXX Vivaldi/XXXXXXXXXX'}
    doc = parse(url_str, opt)
  end

  def img_url(doc)
    doc.css('#imgTagWrapperId > img')[0]['data-old-hires']
  end

  def read(img_url)
    open(img_url).read
  end

  def img_name(img_url)
    File.basename(URI.parse(img_url).path)
  end

  def save_img(name, url_str)
    img_url = img_url(doc(url_str))
    name += File.extname(img_url)
    File.write(name, read(img_url))
  end
end


Kasitime.get(77645)
