# terminal titles & vcs refresh
case $TERM in
  xterm*|urxvt|(u|dt|k|E)term)
    precmd() {
      vcs_info
      print -nP "\033]0;%m: %3~\007"
    }
    preexec() {
      print -nP "\033]0;%m: $1\007"
    }
  ;;

  screen*)
    precmd() {
      vcs_info
      print -nP "\ek%3~\e\\"
      print -nP "\e]0;%3~\a"
      print -nP "\033]0;%m: %3~\007"
    }
    preexec() {
      print -nP "\ek%3~ $1\e\\"
      print -nP "\e]0;%3~ $1\a"
      print -nP "\033]0;%m: $1\007"
    }
  ;;
esac

# change cursor with iTerm
if [ "$TERM_PROGRAM" = "iTerm.app" -o "$TERM_PROGRAM" = "Hyper" ]; then
  function zle-keymap-select zle-line-init {
    if [[ $TMUX != "" ]]; then
      case $KEYMAP in
        vicmd)      print -n -- "\033Ptmux;\033\E]50;CursorShape=0\C-G\033\\";;
        viins|main) print -n -- "\033Ptmux;\033\E]50;CursorShape=1\C-G\033\\";;
      esac
    else
      case $KEYMAP in
        vicmd)      print -n -- "\E]50;CursorShape=0\C-G";;
        viins|main) print -n -- "\E]50;CursorShape=1\C-G";;
      esac
    fi

    zle reset-prompt
    zle -R
  }

  zle -N zle-line-init
  zle -N zle-keymap-select

  function zle-line-finish {
    if [[ $TMUX != "" ]]; then
      print -n -- "\033Ptmux;\033\E]50;CursorShape=0\C-G\033\\"
    else
      print -n -- "\E]50;CursorShape=0\C-G"
    fi
  }

  zle -N zle-line-finish
fi
