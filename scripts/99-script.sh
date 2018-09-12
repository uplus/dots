#!/bin/zsh

ip-sub(){
  ip -4 a show dev "$(ip route show default | awk '{print $5}')" | grep -m1 'inet' | awk '{print $2}'
}

case "$(ip-sub)" in
  133.80.*.*/*)
    logger 'proxy: enable school'
    # echo 'proxy school'
    # proxy-school
    kde-proxy-toggle 1
    ;;
  *)
    logger 'proxy: disable'
    # proxy-off >/dev/null
    kde-proxy-toggle 0
    ;;
esac
