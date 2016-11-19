#!/usr/bin/env ruby
require 'optparse'
require 'find'
require 'fileutils'
Version = 2.0

# zsh complete # {{{
if ARGV[0] == '--complete'
  puts <<-'EOB'
_note(){
  _files -W `note --dir` && return 0
}
compdef _note note
  EOB
  exit
end
# }}}

# add methods to builtin classes # {{{
class String
  def join(*item)
    File.join(self, *item).sub(/\/+$/, '')
  end
end

class File
  def self.mode_is?(path, mode)
    (File.stat(path).mode & mode) == mode
  end
end
# }}}

# helper methods # {{{
def error(message, num, other=nil)
  warn "error: #{message}"
  puts other if other
  exit(num)
end

def goodbye(message=nil)
  puts message
  exit(0)
end

def input(message)
  print "#{message} "
  str = STDIN.gets
  goodbye("^D\nquit.") if str.nil? #C-d
  return str.chomp
rescue Interrupt #C-c
  goodbye
end

# default: "yes" か "no"を渡す
# return: yes -> true, no -> false
def prompt(message, default_mode)# {{{
  if /^yes$/i =~ default_mode
    str = input("#{message} (YES/no)")
    str = 'yes' unless /^no$/i =~ str
  elsif /^no$/i =~ default_mode
    str = input("#{message} (yes/NO)")
    str = 'no' unless /^yes$/i =~ str
  else
    fail "prompt argument error"
  end

  if /^yes$/i =~ str
    return true
  elsif /^no$/i =~ str
    return false
  else
    fail "prompt input error"
  end
end# }}}
# }}}

class Note # {{{
  @@DOCMENTS_DIR = Dir.home.join("Documents")
  @@NOTE_DIR     = @@DOCMENTS_DIR.join("notes")
  @@RC_FILE      = Dir.home.join(".noterc")
  @@GIT_CMD      = "git -C #{@@NOTE_DIR} "

  @@ERROR = {
    document_dir_not_exist: "#{@@DOCMENTS_DIR} is not exist, Please make it.",
    note_dir_is_file:       "#{@@NOTE_DIR} is already exist as file.",
    note_dir_permission:    "#{@@NOTE_DIR} permission is not 0700.",
  }

  # class methods. # {{{
  def self.note_dir_exist? # {{{
    return if File.directory?(@@NOTE_DIR)
    error(@@ERROR[:document_dir_not_exist], 10) unless File.directory?(@@DOCMENTS_DIR)
    error(@@ERROR[:note_dir_is_file],       11) if     File.file?(@@NOTE_DIR)
    error(@@ERROR[:note_dir_permission],    12) unless File.mode_is?(@@NOTE_DIR, 0700)

    if prompt("#{@@NOTE_DIR} not exist, Make it?", "No")
      Dir.mkdir(@@NOTE_DIR, 0700)
    else
      goodbye
    end
  end # }}}

  def self.ls
    system("ls --color=always #{@@NOTE_DIR}")
  end

  def self.tree
    system("tree -C #{@@NOTE_DIR}")
  end

  def self.note_dir
    @@NOTE_DIR
  end

  def self.exec_git_cmd(cmd)
    system(@@GIT_CMD + cmd)
  end

  def self.commit
    exec_git_cmd('add .')
    exec_git_cmd("commit -m \"$(#{@@GIT_CMD} status --short -z | sed -e 's/M //g')\"")
  end

  def self.push
    commit
    exec_git_cmd('push')
  end

  def self.git(cmd)
    unless cmd
      exec_git_cmd('status --short --branch')
      exec_git_cmd('sh')
    else
      exec_git_cmd(cmd)
    end
  end
  # }}}

  # pathを設定して処理を実行する
  def initialize(option)
    path = expansion_name(option[:name])
    path = ask_make_new_file(option) unless path
    send(option[:mode], path)
  rescue => ex
    error("code miss: #{ex.message}", 9, ex.backtrace)
  end

  # alias,abbrev-dirsなどを考慮してパスを取得する
  def expansion_name(name)
    read_aliases_and_abbreviates()
    return @@NOTE_DIR.join(@aliases[name]) if @aliases.has_key?(name)
    search_name(name)
  end

  def read_aliases_and_abbreviates
    @aliases = {}
    @abbreviates = []
    return unless File.file?(@@RC_FILE)

    File.foreach(@@RC_FILE) do |line|
      line.chomp!
      if line.include?(' ')
        @aliases.update([line.split(' ', 2)].to_h)
      else
        @abbreviates << line
      end
    end
  end

  # return the first matched path in @@NOTE_DIR and @abbreviates.
  def search_name(name)
    (@abbreviates + ['./']).each do |dir|
      path = @@NOTE_DIR.join(dir, name)
      return path if File.file?(path)
    end
    nil
  end

  def ask_make_new_file(option)
    error("file not found", 5) unless [:edit, :appen].include?(option[:mode])
    if prompt("#{option[:name]} is not found, make it?", "No")
      make_new_file(option[:name])
    else
      goodbye("quit.")
    end
  end

  def make_new_file(name)
    if name.include?('/')
      new_dir = @@NOTE_DIR.join(name.match('^(.*)/.*$')[1])
      FileUtils.mkdir_p(new_dir, mode: 0700)
    end

    FileUtils.touch(@@NOTE_DIR.join(name)).first
  end

  # actions # {{{
  def append(path)
    body = ARGV.empty? ? input("add>>") : ARGV.join(' ')
    body.gsub!(/(\\n|\\t)/, '\n' => "\n", '\t' => '  ')
    File.open(path) {|file| file.write(body.chomp + "\n") }
  end

  def read(path)
    print File.read(path)
  end

  def less(path)
    system("less -SRn #{path}")
  end

  def edit(path)
    system("$EDITOR #{path}")
  end

  def delete(path)
    if prompt("delete '#{File.basename(path)}' OK?", "No")
      File.delete(path)
      puts 'deleted!'
    else
      puts 'quit.'
    end
  end
  # }}}
end # }}}

#### Entry point ####
Note.note_dir_exist?

USAGE = [ # {{{
  '    You can use \n and \t',
  '    If you want to cancel the input, type Ctrl-D',
  '    note --edit NAME == note NAME',
  '    note --list      == note',
  '',
  '    If you want to complete file names, use this',
  '    note --complete',
] # }}}

# options preparation # {{{

# 引数の置き換え処理がsize <= 3までしか対応してないため
if 3 < ARGV.size
  error("argument size <= 3", 21)
end

# smart arguments
if ARGV.empty?
  ARGV[0] = $stdout.tty? ? '--list' : '--dir'
elsif ARGV.size == 1 && ARGV[0][0] != '-'
  ARGV.unshift('--edit')
elsif ARGV.size == 2 && ARGV[1][0] == '-'
  ARGV.rotate!
elsif ARGV.size == 3 && ARGV[0][0] != '-'
  error("invalid argument order", 22)
end

# check option count
case ARGV.count {|elem| elem[0] == '-' }
when 1
  #OK
when 0
  error("option is not specified", 23)
else
  error("can not use '-' to name", 24)
end
# }}}

# main routine # {{{
OptionParser.new do |opt|
  opt.banner = 'Usage: note [option] [NAME]'
  opt.on('-a', '--append NAME'){|name| Note.new({ mode: :append, name: name }) }
  opt.on('-r', '--read   NAME'){|name| Note.new({ mode: :read,   name: name }) }
  opt.on('-l', '--less   NAME'){|name| Note.new({ mode: :less,   name: name }) }
  opt.on('-e', '--edit   NAME'){|name| Note.new({ mode: :edit,   name: name }) }
  opt.on('-d', '--delete NAME'){|name| Note.new({ mode: :delete, name: name }) }
  opt.on('-g', '--git   [CMD]'){|cmd| Note.git(cmd); exit }
  opt.on('-c', '--commit')  { Note.commit; exit }
  opt.on('-P', '--push')    { Note.push; exit }
  opt.on('-L', '--list')    { Note.ls; exit }
  opt.on('-T', '--tree')    { Note.tree; exit }
  opt.on('-D', '--dir')     { goodbye Note.note_dir }
  opt.on('-h', '--help')    { goodbye [opt, "", USAGE ] }
  opt.parse!(ARGV) rescue error("invalid argument", 25)
end # }}}
