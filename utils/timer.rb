#!/usr/bin/env ruby

loop do
  time = Time.now.strftime('%T.%1L')
  print("\r\e[0J#{time}")
  # \e[H\e[2J

  if /${1:-^}$/ =~ time
    system('xdotool mousedown 1')
    sleep(0.02)
    system('xdotool mouseup 1')
    print("\r\e[0J#{Time.now.strftime('%T.%3L')}")
    break
  end

  sleep(0.03)
end
