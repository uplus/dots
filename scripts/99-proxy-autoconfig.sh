#!/bin/zsh

log_tag='proxy_toggle'

ip-sub(){
  ip -4 a show dev "$(ip route show default | awk '{print $5}')" | grep -m1 'inet' | awk '{print $2}'
}

kde-proxy-toggle() {
  mode="${1:? 0 or 1}"
  user="${2:? username}"

  sudo -E --user="${user}" --group="${user}" kwriteconfig5 --file kioslaverc --group 'Proxy Settings' --key ProxyType "${mode}"
  sudo -E --user="${user}" --group="${user}" dbus-send --type=signal /KIO/Scheduler org.kde.KIO.Scheduler.reparseSlaveConfiguration string:''
}

case "$(ip-sub)" in
  133.80.*.*/*)
    logger 'proxy: enable school'
    kde-proxy-toggle 1
    ;;
  *)
    logger 'proxy: disable'
    # proxy-off >/dev/null
    kde-proxy-toggle 0
    ;;
esac

logger -p user.notice -t "${log_tag}" "configuration done."
