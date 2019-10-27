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

# base16 for shell colors
if [ -d ~/.zsh/plugins/base16-shell/ ]; then
  export BASE16_SHELL=~/.zsh/plugins/base16-shell/

  base16-load() {
    source ~/.base16_theme

    export BASE16_THEME="$(basename $(realpath ~/.base16_theme) .sh)"

    if [ ! -z $TMUX ]; then
      tmux set-environment BASE16_THEME "$BASE16_THEME"
    fi
  }

  base16() {
    local THEME=$1

    if [ ! -z $THEME ]; then
      local FILENAME="base16-$THEME.sh"

      rm -f ~/.base16_theme > /dev/null
      ln -s $BASE16_SHELL/scripts/$FILENAME ~/.base16_theme
      echo -e "colorscheme base16-$THEME" > ~/.vimrc_background
    fi

    base16-load
  }

  # source only if we don't have BASE16_THEME set
  if [ -f ~/.base16_theme ]; then
    local CURRENT_BASE16_THEME="$(basename $(realpath ~/.base16_theme) .sh)"

    if [ -z $BASE16_THEME ] || [ $CURRENT_BASE16_THEME != $BASE16_THEME ]; then
      base16-load
    fi
  fi
fi

