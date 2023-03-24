autoload -Uz colors

# init colors
colors

# grep
export GREP_COLOR=34

# dircolors
load_dircolors() {
  if [ -f ~/.dircolors ]; then
    eval $(dircolors -b ~/.dircolors)
  fi
}
zsh-defer -t 1.0 +1 load_dircolors

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

  # update all opened terms on mac os by sending the color values directly to the tty
  # TODO: this could be extended to support linux
  # reference:
  # - https://writing.grantcuster.com/posts/2020-07-12-swapping-color-schemes-across-all-terminals-and-vim-with-pywal-and-base16/
  # - https://github.com/dylanaraps/pywal/blob/42ad8f014dfe11defe094a3ce33b60f7ec27b83b/pywal/sequences.py#L83
  base16_send() {
    # this is still broken!
    # something about different escape codes for tmux and non-tmux
    for tty in /dev/ttys00[0-9]*; do
      if tmux list-clients | grep -q $tty; then
        TMUX="FORCE_TMUX" base16_load > $tty
      else
        TMUX="" base16_load > $tty
      fi
    done
  }

  base16_load() {
    source ~/.base16_theme
    # export BASE16_THEME="$(basename $(realpath ~/.base16_theme) .sh)"
  }

  base16() {
    local THEME=$1

    if [ ! -z $THEME ]; then
      local FILENAME="base16-$THEME.sh"

      rm -f ~/.base16_theme > /dev/null
      ln -s $BASE16_SHELL/scripts/$FILENAME ~/.base16_theme
      echo -e "colorscheme base16-$THEME" > ~/.vimrc_background
    fi

    base16_load
  }

  # source only if we don't have BASE16_THEME set
  if [ -f ~/.base16_theme ]; then
    local CURRENT_BASE16_THEME="$(basename $(realpath ~/.base16_theme) .sh)"

    if [ -z $BASE16_THEME ] || [ $CURRENT_BASE16_THEME != $BASE16_THEME ]; then
      base16_load
    fi
  fi
fi

