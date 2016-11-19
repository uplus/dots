#!/usr/bin/env zsh
set -ue

voice=$HOME/Documents/voices/miku-a.htsvoice
dict=/usr/local/share/open_jtalk/open_jtalk_dic_utf_8-1.08/
out=/tmp/jsay-voice.wav
rm -f $out

echo "${1}" |  open_jtalk -m $voice -x $dict -ow $out -s 48000 -z 12000 \
-g -25 \
-r 1.3 \
-fm 1 \

aplay $out >/dev/null 2>&1

# -p  i : frame period (point)       [auto][   1--    ] 単純な速度
# -r  f : speech speed rate          [ 1.0][ 0.0--    ] スピーチ速度

# -b  f : postfiltering coefficient  [ 0.0][ 0.0-- 1.0] 音の揺らぎ(最大だと拡張器で割れたような音)
# -u  f : voiced/unvoiced threshold  [ 0.5][ 0.0-- 1.0] 有音/無音境界 小:普通 大:途切れた感じ
# -a  f : all-pass constant          [auto][ 0.0-- 1.0] 小:高音 大:低音
# -fm f : additional half-tone       [ 0.0][    --    ] 追加ハーフトーン 小:低音 高:高音
# -jm f : weight of GV for spectrum  [ 1.0][ 0.0--    ] 抑揚 小:小さい 大:大きい
# -jf f : weight of GV for log F0    [ 1.0][ 0.0--    ] 声量

# -ot s : filename of output trace information     [  N/A]
# -s  i : sampling frequency                       [ auto][   1--    ]
# -g  f : volume (dB)                              [  0.0][    --    ]
# -z  i : audio buffer size (if i==0, turn off)    [    0][   0--    ]
