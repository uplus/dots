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
  p 'Cause redirect'
  p url_str,opt
  url_str = e.uri.to_s
  retry
rescue RuntimeError => e
  p 'RuntimeError'
  opt[:redirect] = false
  retry
end

def title(doc)
  doc.css('.person_list_and_other_contents > h1').text.rstrip
end

def img_url(doc)
 doc.css('#imgTagWrapperId > img')[0]['data-old-hires']
end


# url = 'https://www.amazon.co.jp/gp/product/B007BHFVGI/ref=as_li_qf_sp_asin_il?ie=UTF8&camp=247&creative=1211&creativeASIN=B007BHFVGI&linkCode=as2&tag=kasi-22'
url = 'https://www.amazon.co.jp/Burst-Gravity-初回限定盤-ALTIMA/dp/B0083GTWMK/ref=pd_bxgy_15_img_2?_encoding=UTF8&psc=1&refRID=4AQGC0GJ7KB66HN85YTE'
# url = 'http://amzn.asia/arNhAo6'
# url = 'https://www.amazon.co.jp/dp/B0084GTWMK/ref=cm_sw_r_cp_ep_dp_kX5sybKFG41Vl2'
# url = 'https://goo.gl/FuiQjc'

opt = { 'User-Agent' => 'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_10_5) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/XXXXXXXXXXXXX Safari/XXXXXX Vivaldi/XXXXXXXXXX'}
doc = parse(url, opt)

img_url = img_url(doc)
img_name = File.basename(URI.parse(img_url).path)
File.write(img_name, open(img_url).read)

binding.pry
