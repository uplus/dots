#!/usr/bin/env ruby

finish_time = ARGV[0] || '^'

loop do
  time = Time.now.strftime('%T.%1L')
  print("\r\e[0J#{time}")
  # \e[H\e[2J

  if /#{finish_time}$/ =~ time
    system('xdotool mousedown 1')
    sleep(0.025)
    system('xdotool mouseup 1')
    print("\r\e[0J#{Time.now.strftime('%T.%3L')}")
    break
  end

  sleep(0.03)
end
