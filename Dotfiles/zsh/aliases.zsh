alias sudo="sudo "

alias ls="LC_COLLATE=C ls --color=auto --group-directories-first --classify --human-readable"
alias ll="LC_COLLATE=C ls --color=auto --group-directories-first --classify --human-readable -l"
alias la="LC_COLLATE=C ls --color=auto --group-directories-first --classify --human-readable -l --almost-all"

alias rm="rm -iv"
alias mv="mv -iv"
alias cp="cp -iv -R"

alias back="cd - > /dev/null"
alias jumps="j | cut -b12- | tail -10"
alias dirs="dirs -v"
alias mkdir="mkdir -p"
alias cdtemp="cd $(mktemp -d)"

alias df="df -h"
alias du="du -sh"

alias rg="rg --smart-case"
alias grep="egrep --color=auto"
alias less="less -i --tabs=2 -r"
alias diff="colordiff"
alias wget="wget -c"
alias watch="watch -n1 -c -t"
alias picocom="picocom -e x"

alias globalip="dig +short myip.opendns.com @resolver1.opendns.com"
alias sniff="sudo ngrep -d 'en1' -t '^(GET|POST) ' 'tcp and port 80'"
alias httpdump="sudo tcpdump -i en1 -n -s 0 -w - | grep -a -o -E \"Host\: .*|GET \/.*\""

alias x="exit"
alias c="clear"

alias t="tree -aC --dirsfirst -I '.git|node_modules|bower_components'"
alias td="tree -adC --dirsfirst -I '.git|node_modules|bower_components'"

alias tl="tmux ls | sed 's/:/;/' | sed 's/\[.*\]//g' | column -t -s ';' | sed 's/(.*) //'"

alias today="$EDITOR +Today"

alias timestamp="date +%Y%m%d-%H%M"
alias datestamp="date +%Y-%m-%d"

alias -g C="| wc -l"                 # [C]ount
alias -g G="| egrep -i --color=auto" # [G]rep
alias -g H="| head"                  # [H]ead
alias -g T="| tail"                  # [T]ail
alias -g L="| less"                  # [L]ess
alias -g P="| pbcopy"                # [P]bcopy
alias -g B="> /dev/null 2>&1 &"      # [B]lank
alias -g N="; notify-terminal"       # [N]otify

# execute last command and use its output
# stolen from https://github.com/narfdotpl/dotfiles/blob/master/home/.zshrc
#   $ find . -name "foo*py"
#   ./qwe/rty/foobar.py
#   $ git log ^
alias -g ^='$(fc -e - 2> /dev/null)'

