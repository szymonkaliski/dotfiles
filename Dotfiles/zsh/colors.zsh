autoload -Uz colors

# init colors
colors

# grep
export GREP_COLOR=34

# dircolors
if [ -f ~/.dircolors ]; then
  eval $(dircolors -b ~/.dircolors)
fi

# grc for commands
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
