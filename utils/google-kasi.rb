#!/usr/bin/env ruby
require_relative File.join(Dir.home, '.dots/utils/lyrics.rb')
require 'optparse'
require 'curses'

def parse_ansicolor(str)
  return [''] if str.empty?
  str.scan(/(?<str>[^\e]+)|\e\[(\d+;)*(?<num>\d+)m/).map{|m| m[1]&.to_i || m[0]}
end

def color_str(color_num, str)
  "\e[38;5;#{color_num}m#{str}\e[00m"
end

def round_multiple(value, unit)
  (value/unit)*unit
end

def input_num(str)
  print str
  gets&.strip.to_i
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
  system('tycat', '-g', '40x0', path) if terminology?
end

class String # {{{
  def count_width
    each_char.map(&:width).inject(0, :+) # 初期値が無いと空文字のときnilになる
  end

  def width
    self.ascii_only? ? 1: 2
  end

  def color(num)
    "\e[38;5;#{num}m#{self}\e[00m"
  end
end # }}}

class Less # {{{
  attr_reader :scr, :pad

  def initialize(strings, top=0, left=0)
    @scr = Curses.init_screen
    Curses.cbreak
    Curses.noecho
    Curses.curs_set(0)
    Curses.start_color
    Curses.color_pairs.times{|n| Curses.init_pair(n, n, Curses::COLOR_BLACK)}
    @pad = Pad.new(strings, top, left, height-top, width-left) # 1でもはみ出ると何も表示されない
  end

  def finalize # {{{
    Curses.curs_set(1)
    Curses.echo
    Curses.nocbreak
    Curses.close_screen
  end # }}}

  def height
    scr.maxy-1
  end

  def width
    scr.maxx-1
  end

  def header(&block)
    @header_block = block
  end

  def addcstr(str, color=0)
    Curses.attron(Curses.color_pair(color)){ Curses.addstr(str.to_s) }
  end

  def show
    loop do
      Curses.clear
      @header_block.call(self) if @header_block
      Curses.refresh
      return [pad.x, pad.y, pad.input_num] if pad.show
    end
  ensure
    finalize
  end

  class Pad # {{{
    attr_reader :pad, :height, :width,
                :win_area, :x, :y, :x_step, :y_step

    def initialize(strings, top,left, height,width)
      @input_num = ''
      @height,@width = height,width
      @win_area = [top,left, top+height, left+width].freeze # upper-left, lower-right
      move(0,0)
      step(1,1)
      make_pad(strings)
    end

    def make_pad(strings)
      strings.map!{|line| parse_ansicolor(line)}
      @lines_length = strings.map{|line| line.grep(String).map(&:count_width).inject(:+)}
      @pad = Curses::Pad.new(strings.size, @lines_length.max+2) # 改行記号の分
      pad.keypad = true

      strings.each do |line|
        # addcstrとして切り出せる
        line.each do |elem|
          if Integer === elem
            pad.attrset(Curses.color_pair(elem)|Curses::A_NORMAL)
          else
            pad.addstr(elem)
          end
        end
        pad.addstr("⏎\n")
        pad.attrset(Curses::A_NORMAL)
      end
      pad.refresh(y, x, *win_area) # 事前に必要
    end

    def input_num
      Integer(@input_num) rescue nil
    end

    def show
      pad.refresh(y, x, *win_area)
      return key_input
    end

    def move(x,y)
      @x,@y = x,y
    end

    def step(x,y)
      @x_step,@y_step = x,y
    end

    # Enter: true
    # Other: false
    def key_input # {{{
      case c = pad.getch
      when 'h', Curses::KEY_LEFT
        @x -= x_step
      when 'j', Curses::KEY_DOWN
        @y += y_step
      when 'k', Curses::KEY_UP
        @y -= y_step
      when 'l', Curses::KEY_RIGHT
        @x += x_step
      when Curses::KEY_CTRL_B
        @y -= round_multiple(height, y_step)
      when Curses::KEY_CTRL_F
        @y += round_multiple(height, y_step)
      when Curses::KEY_CTRL_U
        @y -= round_multiple(height/2, y_step)
      when Curses::KEY_CTRL_D
        @y += round_multiple(height/2, y_step)
      when Curses::KEY_HOME, Curses::KEY_CTRL_A
        @y = 0
      when Curses::KEY_END, Curses::KEY_CTRL_E
        @y = pad.maxy-1
      when "\n".ord, Curses::KEY_ENTER
        return true
      when /\d/
        @input_num += c
      when Curses::KEY_BACKSPACE
        @input_num.sub!(/.\z/, '')
      end

      @x = 0 if @x < 0
      @y = 0 if @y < 0
      @y = pad.maxy-y_step if pad.maxy <= @y
      return false
    end # }}}
  end # }}}
end # }}}

class GoogleSelect < Google # {{{
  def select_one
    return nil if size == 0
    if size == 1
      puts put_cand_default(0, cands[0]).join("\n")
      return cands[0]
    end

    l = Less.new(yield(cands), 1)
    l.pad.step(8, 3)
    l.header do |me|
      me.addcstr('Number> ', 214)
      me.addcstr(me.pad.input_num)
    end

    l.show
    cands[l.pad.input_num] rescue nil
  end
end # }}}

def put_cand_correct_info(i, cand)
  unless /^\/item/ =~ URI.parse(cand[:url]).path
    return ("%{title}(%{url})\n" % cand).color(184)
  end

  kasi = Kasitime.new(cand[:url])
  lyrics = kasi.lyrics.gsub("\n", ' ')[0..60]
  return ["#{i} #{kasi.info_str.color(111)}", lyrics] # Unverified
end

def put_cand_default(i, cand)
  unless /^\/item/ =~ URI.parse(cand[:url]).path
    return ("%{title}(%{url})\n" % cand).color(184)
  end

  title = cand[:title].sub(/\s*-\s*歌詞タイム\s*\z/, '')
  info,lyrics = cand[:desc].split('歌い出し:')
  info,lyrics = nil,info unless lyrics # 歌詞のみの場合がある
  return ["#{i} #{title.color(111)} -- #{info}", lyrics]
end

begin
  google = GoogleSelect.new('www.kasi-time.com', ARGV.shift)
  cand = google.select_one do |cands|
    cands.map.with_index{|cand, i| [*put_cand_default(i, cand), '']}.flatten
  end
  exit unless cand

  kasi = Kasitime.new(cand[:url])
  case input_num('[0:read, 1:save, 2:thumbnail, 9:save all, other: quit]> ')
  when 0
    Less.new(kasi.lyrics.split("\n")).show
  when 1
    kasi.save_lyrics
  when 2
    show_img(kasi.save_thumbnail)
  when 9
    Less.new(kasi.save_lyrics.split("\n")).show
    kasi.save_thumbnail
  end
rescue => e
  puts 'Error'
  puts e, e.message, e.backtrace
  binding.pry
end


exit

# Make DB
opts = {}
parser = OptionParser.new do |o|
  o.on('-c', '--correct', 'Show correct information of candidates with to parse each web page.')
  o.on('-n', '--number', 'Set candidates number of google')
  o.on('-T', '--show-thumbnail', 'Show thumbnail in current terminal(Terminology only)')
  o.on('-C', '--clear-cache'){|v| opts[:clear_cache] = v}
end
