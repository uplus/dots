#!/usr/bin/env ruby
require 'find'
require 'optparse'
require 'shellwords'
require 'open3'

class Hash
  def symbolize_keys
    self.each_with_object({}) {|(k,v), m| m[k.to_sym] = v }
  end
end

def regexps_from_file(path)
  File.readlines(path).map {|p| Regexp.new(p.strip,Regexp::IGNORECASE) }
end

def get_option
  opt = ARGV.getopts('', "num:20", "dir:~/Music", "play:vlc").symbolize_keys
  opt[:num] = opt[:num].to_i
  opt[:dir] = File.expand_path(opt[:dir]) + '/'
  opt
end

def is_ignore?(file)
  IGNORE_PATTERNS.any? {|regexp| regexp =~ file}
end

def getmusics(dir)
  musics = Find.find(dir).select {|f| /\.(mp3|wav)$/ =~ f }
  musics.reject {|file| is_ignore?(file) }
end

def music_select(files, num)
  files.shuffle.sample(num)
end

def escape(files)
  files.map {|f| f.shellescape }
end

IGNORE_FILE = File.join(Dir.home, '.bgm_ignore').freeze
IGNORE_PATTERNS = (File.file?(IGNORE_FILE)? regexps_from_file(IGNORE_FILE) : []).freeze

=begin
  -n {NUM}  Number
  -d {DIR}  Directory default is ~/Music/
  -p {play} Player   default is vlc
=end


option         = get_option()
all_files      = getmusics(option[:dir])
selected_files = music_select(all_files, option[:num])
escaped_files  = selected_files.map {|f| f.shellescape }
puts selected_files.sort

begin
  # Open3.capture3("%s %s >/dev/null 2>&1 &" % [option[:play], escaped_files.join(' ')])
  Open3.capture3(option[:play], *selected_files)
rescue => e
  puts e, e.backtrace
  puts "\n#arg files"
  selected_files.zip(escaped_files) {|str,esc| p str, esc }
end
