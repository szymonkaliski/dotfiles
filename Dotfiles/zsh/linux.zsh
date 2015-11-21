alias localip="ifconfig eth0 | grep inet | awk '{ print \$2 }'"
alias reboot="sudo systemctl reboot"
alias shutdown="sudo systemctl poweroff"
