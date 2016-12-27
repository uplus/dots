#!/usr/bin/env ruby
require_relative File.join(Dir.home, '.dots/utils/lyrics.rb')
require_relative File.join(Dir.home, 'codes/smp/ruby/curses-pad-less.rb')

require 'optparse'

def color_str(color_num, str)
  "\e[38;5;#{color_num}m#{str}\e[00m"
end

def pager
  $stdout = out = StringIO.new
  return yield
ensure
  $stdout = STDOUT
  opt='--RAW-CONTROL-CHARS --quit-if-one-screen --no-init'
  IO.popen(['less', opt], 'w'){|f| f.puts out.string }
end

def input_num(str)
  print str
  gets&.to_i
rescue Interrupt
  nil
end

def get_pid_stat(pid)
  pid, comm, state, ppid =  File.read("/proc/#{pid}/stat").split[0..3]
  {pid: pid.to_i, comm: comm.sub(/\((.*)\)/, '\1'), state: state, ppid: ppid.to_i}
end

def list_parents(pid)
  parents = [get_pid_stat(pid)]

  loop do
    p = parents.last
    return parents if p[:pid] == 1
    parents << get_pid_stat(p[:ppid])
  end
end

def terminology?
  list_parents(Process.pid).any?{|p| p[:cmd] = 'terminology' }
end

def show_img(path)
  system('tycat -g 50x0', path) if terminology?
end


class Google < Scraping
  @@baseurl = 'https://www.google.co.jp/search?q=site:%s+intitle:%s&num=%d'.freeze

  def initialize(site, word, num=10)
    super(self.class.url(site, word, num))
  end

  def each
    cands.each
  end

  def size
    cands.size
  end

  # return [{title: , url: , desc: }]
  def cands
    @cands ||= doc.css('#search .g').map do |cand|
      {title: cand.at_css('.r > a').text,
       url: 'http://'+cand.at_css('.s > div > cite').text,
       desc: cand.at_css('.st').text.gsub("\n", ''),}
    end
  end

  # show candidates and select it interactively
  def select_one
    return cands[0] if size <= 1

    strings = []
    each.with_index do |cand, i|
      strings.push(*yield(i, cand), '')
    end

    l = Less.new(strings, 1)
    l.pad.step(8, 3)
    l.header do |me|
      me.scr.addcstr('Number> ', 214)
      me.scr.addcstr(me.pad.input_num)
    end

    l.show
    cands[l.pad.input_num] rescue nil
  end

  def self.url(site, word, num=10)
    @@baseurl % [site, word, num]
  end
end

def put_cand_correct_info(i, cand)
  unless /^\/item/ =~ URI.parse(cand[:url]).path
    puts color_str(184, "%{title}(%{url})\n" % cand)
    return
  end

  kasi = Kasitime.new(cand[:url])
  lyrics = kasi.lyrics.gsub("\n", ' ')[0..60]
  return [["#{i} #{kasi.info_str}", 111], lyrics] # TODO test
end

def put_cand_default(i, cand)
  unless /^\/item/ =~ URI.parse(cand[:url]).path
    return [["%{title}(%{url})\n" % cand, 184]]
  end

  title = cand[:title].sub(/\s*-\s*歌詞タイム\s*\z/, '')
  info,lyrics = cand[:desc].split('歌い出し:')
  info,lyrics = nil,info unless lyrics # 歌詞のみの場合がある

  return [["#{i} #{title} -- #{info}", 111], lyrics]
end

begin
  res = Google.new('www.kasi-time.com', ARGV.shift)
  cand = res.select_one(&method(:put_cand_default))
  exit unless cand

  p cand
  url = cand[:url]

  binding.pry

  kasi = Kasitime.new(url)
  # case input_num('[0:all, 1:lyrics, 2:thumbnail, other: quit]> ')
  case input_num('[0:read lyrics, 1:save lyrics, 2:save thumbnail, 9:save all, other: quit]> ')
  when 0
    Less.new(kasi.lyrics.gsub(/^\n$/, ' ').split("\n")).show
  when 1
    kasi.save_lyrics
  when 2
    # TODO show graphics in terminal
    kasi.save_thumbnail
  when 9
    l = Less.new(kasi.save_lyrics.split)
    l.show
    kasi.save_thumbnail
  end
rescue => e
  puts 'Error'
  puts e, e.message, e.backtrace
  binding.pry
end




exit

opts = {}
parser = OptionParser.new do |o|
  o.on('-c', '--correct', 'Show correct information of candidates with to parse each web page.')
  o.on('-n', '--number', 'Set candidates number of google')
  o.on('-T', '--show-thumbnail', 'Show thumbnail in current terminal(Terminology only)')
  o.on('-C', '--clear-cache'){|v| opts[:clear_cache] = v}
end
