alias localip="ifconfig eth0 | grep inet | awk '{ print \$2 }'"
alias reboot="sudo systemctl reboot"
alias shutdown="sudo systemctl poweroff"

toggle_vpn() {
  if ifconfig | grep -q "ppp"; then
    echo "Turning VPN off"
    sudo poff vpn
  else
    echo "Turning VPN on"
    sudo pon vpn
  fi
}
