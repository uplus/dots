#!/usr/bin/env ruby
chpwd_file = File.expand_path(ARGV[0] || '~/.zsh/chpwd-recent-dirs')
lines = File.readlines(chpwd_file)
          .map{|line| line.chomp[2..-2]}
          .select{|line| File.exist?(line)}
          .map{|line| "$'#{line}'"}
          .sort

File.write(chpwd_file, lines.join("\n") + "\n")
