require 'open-uri'
require 'nokogiri'
require 'pry'

def parse(url, opt={})
  charset = nil
  html = open(URI.encode(url), opt) do |f|
    charset = f.charset
    f.read
  end

  Nokogiri::HTML.parse(html, nil, charset)
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

url = 'http://www.kasi-time.com/item-%d.html' % 62654
doc = parse(url)
lyrics = lyrics(doc)

p lyrics

binding.pry

# https://images-na.ssl-images-amazon.com/images/I/71S3CH%2BE0YL._SL1100_.jpg
