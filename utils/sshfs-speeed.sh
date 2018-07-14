#!/bin/bash
# http://d.hatena.ne.jp/hirose31/20110712/1310457485

usage() { echo "[usage] ./m hostname"; exit 1; }
[ $# -eq 1 ] || usage

rhost=${1%/}
[ -d "$rhost" ] || mkdir "$rhost"
sshfs \
  -o cache_timeout=3 \
  -o transform_symlinks \
  -o workaround=rename \
  -o ssh_command=ssh4sshfs \
  $rhost:/ $rhost \
    ;
df -t fuse.sshfs -h
