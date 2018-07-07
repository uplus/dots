#!/usr/bin/env ruby

def to_i2(s)
  s.to_i(2)
end

def converter_base(is_subnetmask, slashnum)
  head, tail = is_subnetmask ? ['1', '0'] : ['0', '1']
  (head * slashnum + tail * (32 - slashnum))
    .scan(/.{8}/)
    .map(&method(:to_i2))
    .join('.')
end

def slashnum_to_subnetmask(slashnum)
  converter_base(true, slashnum)
end

def slashnum_to_wildcard(slashnum)
  converter_base(false, slashnum)
end

slashnum = 4

pp slashnum_to_subnetmask(slashnum)
pp slashnum_to_wildcard(slashnum)
