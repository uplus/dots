#! /usr/bin/env ruby

require 'rmagick'
require 'io/console/size'
require 'optparse'

opt = OptionParser.new
opt.on('-s', '--sample'){ @r_method = :sample }
opt.on('-g', '--grayscale'){ @gray_only = true }
opt.parse! ARGV

RESIZE_METHOD = @r_method || :resize
GRAY_ONLY = @gray_only
WIDTH = IO::console_size.last

def esc(red, green, blue, limit = 255, bg: true)
  rgb = [red, green, blue]
  max, min = rgb.max, rgb.min

  if GRAY_ONLY || max - min < (limit / 23r).round
    c = (max + min) / 2
    color = (23r * c / limit).round + 232
  else
    rgb.map!{|c| (5r * c / limit).round }
    color = rgb.join.to_i(6) + 16
  end

  "\e[#{bg ? 48 : 38};5;#{color}m"
end

class Magick::Pixel
  def to_esc
    esc red, green, blue, 65535
  end
end

class Magick::Image
  def to_esc
    get_pixels(0, 0, columns, rows).map do |pix|
      "#{pix.to_esc} \e[m"
    end.each_slice(columns).map do |line|
      line.join
    end * "\n"
  end
end

ARGV.each do |path|
  img = Magick::Image.read(path).first
  cols = WIDTH
  rows = (WIDTH / 2r / img.columns * img.rows).round
  puts img.method(RESIZE_METHOD).call(cols, rows).to_esc
end
