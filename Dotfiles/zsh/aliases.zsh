if hash nvim 2> /dev/null; then
  export EDITOR="nvim"
else
  export EDITOR="vim"
fi

alias e=$EDITOR
alias v=$EDITOR
alias n="nvim"
alias sudo="sudo "

alias ls="LC_COLLATE=C ls --color=auto --group-directories-first --classify --human-readable"
alias ll="LC_COLLATE=C ls --color=auto --group-directories-first --classify --human-readable -l"
alias la="LC_COLLATE=C ls --color=auto --group-directories-first --classify --human-readable -l --almost-all"

alias rm="rm -iv"
alias mv="mv -iv"
alias cp="cp -iv"

alias back="cd - > /dev/null"
alias jumps="j | cut -b12- | tail -10"
alias dirs="dirs -v"
alias mkdir="mkdir -p"

alias df="df -h"
alias du="du -sh"
alias ag="ag --smart-case"

alias grep="egrep --color=auto"
alias less="less -i --tabs=2"
alias diff="colordiff"
alias wget="wget -c"
alias watch="watch -n1 -c -t"

alias ip="dig +short myip.opendns.com @resolver1.opendns.com"
alias sniff="sudo ngrep -d 'en1' -t '^(GET|POST) ' 'tcp and port 80'"
alias httpdump="sudo tcpdump -i en1 -n -s 0 -w - | grep -a -o -E \"Host\: .*|GET \/.*\""

alias x="exit"
alias c="clear"

alias t="tree -aC -I '.git|node_modules|bower_components'"
alias td="tree -adC -I '.git|node_modules|bower_components'"

alias tl="tmux ls | sed 's/:/;/' | sed 's/\[.*\]//g' | column -t -s ';'"

alias -g C="| wc -l"
alias -g G="| egrep -i --color=auto"
alias -g H="| head"
alias -g T="| tail"
alias -g L="| less"
alias -g M="| more -i"
alias -g S="| sort"
alias -g B="> /dev/null 2>&1 &"

alias -g N="; notify-terminal"
alias -g P="; pushover-terminal"
