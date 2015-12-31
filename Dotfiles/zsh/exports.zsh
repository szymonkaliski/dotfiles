if hash nvim 2> /dev/null; then
  export EDITOR="nvim"
else
  export EDITOR="vim"
fi

export HOMEBREW_NO_EMOJI=1
export MOSH_TITLE_NOPREFIX=1
