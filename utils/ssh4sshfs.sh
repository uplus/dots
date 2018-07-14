#!/bin/sh
# http://d.hatena.ne.jp/hirose31/20110712/1310457485

exec ssh -o ControlPath=none -C -c arcfour128,arcfour256,arcfour,aes128-cbc,3des-cbc,blowfish-cbc,cast128-cbc,aes192-cbc,aes256-cbc "$@"
