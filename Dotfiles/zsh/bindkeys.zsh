bindkey "^[b"   backward-word
bindkey "^[f"   forward-word
bindkey "^[[2~" overwrite-mode
bindkey "^[[3~" delete-char
bindkey "^[[5~" up-line-or-search
bindkey "^[[6~" down-line-or-search
bindkey "^R"    history-incremental-search-backward
bindkey "^[[A"  history-beginning-search-backward
bindkey "^[[B"  history-beginning-search-forward

bindkey -M vicmd "L" end-of-line
bindkey -M vicmd "H" beginning-of-line

case $TERM in
  *xterm*|urxvt|(u|dt|k|E)term)
    bindkey "^[[H" beginning-of-line
    bindkey "^[[F" end-of-line
  ;;
  *screen*)
    bindkey "^[[1~" beginning-of-line
    bindkey "^[[4~" end-of-line
  ;;
esac

# edit current command line
autoload -z edit-command-line
zle -N edit-command-line
bindkey "^X^E" edit-command-line

# ctrl-z for fg/bg switch
function fg-bg() {
  if [[ $#BUFFER -eq 0 ]]; then
    fg
  else
    zle push-input
  fi
}

zle -N fg-bg
bindkey '^Z' fg-bg
