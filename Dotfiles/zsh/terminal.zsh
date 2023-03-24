# terminal titles & vcs refresh
case $TERM in
  *xterm*)
    precmd() {
      print -nP "\033]0;%m: %3~\007"
    }
    preexec() {
      print -nP "\033]0;%m: $1\007"
    }
  ;;

  *screen*|*tmux*)
    precmd() {
      print -nP "\ek%3~\e\\"
      print -nP "\e]0;%3~\a"

      # session-name: dir
      # print -nP "\033]0;${(C)$(tmux display-message -p '#S')}: %3~\007"
      print -nP "\033]0;$(tmux display-message -p '#S'): %3~\007"
    }
    preexec() {
      print -nP "\ek%3~ $1\e\\"
      print -nP "\e]0;%3~ $1\a"

      # session-name: cmd
      # print -nP "\033]0;${(C)$(tmux display-message -p '#S')}: $1\007"
      print -nP "\033]0;$(tmux display-message -p '#S'): $1\007"
    }
  ;;
esac

# change cursor depending on mode
# if [ "$TERM_PROGRAM" = "iTerm.app" -o "$TERM_PROGRAM" = "iTerm2.app" ]; then
#   function zle-keymap-select zle-line-init {
#     if [[ $TMUX != "" ]]; then
#       case $KEYMAP in
#         vicmd)      print -n -- "\033Ptmux;\033\E]50;CursorShape=0\C-G\033\\";;
#         viins|main) print -n -- "\033Ptmux;\033\E]51;CursorShape=1\C-G\033\\";;
#       esac
#     else
#       case $KEYMAP in
#         vicmd)      print -n -- "\E]50;CursorShape=0\C-G";;
#         viins|main) print -n -- "\E]51;CursorShape=1\C-G";;
#       esac
#     fi
#   }

#   function zle-line-finish {
#     if [[ $TMUX != "" ]]; then
#       print -n -- "\033Ptmux;\033\E]50;CursorShape=0\C-G\033\\"
#     else
#       print -n -- "\E]50;CursorShape=0\C-G"
#     fi
#   }

#   zle -N zle-line-init
#   zle -N zle-keymap-select
#   zle -N zle-line-finish
# fi

# https://github.com/kovidgoyal/kitty/issues/715
# if [ "$TERM_PROGRAM" = "kitty" -o "$TERM_PROGRAM" = "tmux" ]; then
  function zle-keymap-select zle-line-init zle-line-finish {
    case $KEYMAP in
      vicmd)      print -n '\033[1 q';;
      viins|main) print -n '\033[5 q';;
    esac
  }

  zle -N zle-line-init
  zle -N zle-line-finish
  zle -N zle-keymap-select
# fi
