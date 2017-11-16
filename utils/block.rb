#!/usr/bin/env ruby

if ARGV.size < 1
  puts 'usage: block "start_pattern" ["end_pattern"]'
  puts 'e.g. objdump -S <bin> | block "start_pattern" "end_pattern"'
  exit 1
end

ARGV[1] ||= "^$"
start_pattern = Regexp.new(ARGV[0].gsub('\n', "\n"));
end_pattern   = Regexp.new(ARGV[1].gsub('\n', "\n"));

out_on = false
while line = STDIN.gets
  if out_on
    out_on = false if !ARGV[1].empty? && end_pattern =~ line
  else
    out_on = true if start_pattern =~ line
  end

  if out_on
    puts line
  end
end
