autoload -U colors

# init colors
colors

# grep
export GREP_COLOR=34

# dircolors
if [ -f ~/.dircolors ]; then
  eval $(dircolors -b ~/.dircolors)
fi

# # grc for commands
if hash grc 2> /dev/null; then
  alias colourify="grc -es --colour=auto"

  alias diff="colourify diff"
  alias make="colourify make"
  alias gcc="colourify gcc"
  alias g++="colourify g++"
  alias ld="colourify ld"
  alias netstat="colourify netstat"
  alias ping="colourify ping"
  alias traceroute="colourify traceroute"
fi

# # live command highlighting like fish
if [ -f ~/.zsh/plugins/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh ]; then
  source ~/.zsh/plugins/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh

  ZSH_HIGHLIGHT_HIGHLIGHTERS=(main brackets) # pattern

  # ZSH_HIGHLIGHT_PATTERNS+=('rm -rf *' 'fg=black,bg=red')
  # ZSH_HIGHLIGHT_PATTERNS+=('ssh *' 'fg=black,bg=blue')

  ZSH_HIGHLIGHT_STYLES[precommand]='fg=magenta'
  ZSH_HIGHLIGHT_STYLES[commandseparator]='fg=yellow'
  ZSH_HIGHLIGHT_STYLES[path]='none'
  ZSH_HIGHLIGHT_STYLES[path_prefix]='none'
  ZSH_HIGHLIGHT_STYLES[path_approx]='none'
  ZSH_HIGHLIGHT_STYLES[single-hyphen-option]='fg=yellow'
  ZSH_HIGHLIGHT_STYLES[double-hyphen-option]='fg=yellow'
  ZSH_HIGHLIGHT_STYLES[back-quoted-argument]='fg=magenta'
  ZSH_HIGHLIGHT_STYLES[single-quoted-argument]='fg=red'
  ZSH_HIGHLIGHT_STYLES[double-quoted-argument]='fg=red'
fi

# less & man colors
# export LESSCHARSET="utf-8"
# export LESS_TERMCAP_mb=$(tput setaf 2)
# export LESS_TERMCAP_md=$(tput setaf 6)
# export LESS_TERMCAP_me=$(tput sgr0)
# export LESS_TERMCAP_so=$(tput setaf 3; tput setab 4)
# export LESS_TERMCAP_se=$(tput rmso; tput sgr0)
# export LESS_TERMCAP_us=$(tput smul; tput setaf 7)
# export LESS_TERMCAP_ue=$(tput rmul; tput sgr0)
# export LESS_TERMCAP_mr=$(tput rev)
# export LESS_TERMCAP_mh=$(tput dim)
# export LESS_TERMCAP_ZN=$(tput ssubm)
# export LESS_TERMCAP_ZV=$(tput rsubm)
# export LESS_TERMCAP_ZO=$(tput ssupm)
# export LESS_TERMCAP_ZW=$(tput rsupm)
# export LESS="-R --RAW-CONTROL-CHARS"

