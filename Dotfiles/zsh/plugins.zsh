# z for better jumps
if [ -f ~/.zsh/plugins/z/z.sh ]; then
  source ~/.zsh/plugins/z/z.sh
fi

# bd for better up
if [ -f ~/.zsh/plugins/zsh-bd/bd.zsh ]; then
  source ~/.zsh/plugins/zsh-bd/bd.zsh
fi

# better pairs
if [ -f ~/.zsh/plugins/zsh-bd/bd.zsh ]; then
  source ~/.zsh/plugins/zsh-autopair/autopair.zsh
fi

# live command highlighting like fish
if [ -f ~/.zsh/plugins/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh ]; then
  source ~/.zsh/plugins/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh

  ZSH_HIGHLIGHT_HIGHLIGHTERS=(main) # pattern

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

zsh_plugins_install() {
  local LAST_PWD=$(pwd)

  mkdir -p ~/.zsh/plugins/
  cd ~/.zsh/plugins/

  git clone git://github.com/Tarrasch/zsh-bd
  git clone git://github.com/hlissner/zsh-autopair
  git clone git://github.com/rupa/z.git
  git clone git://github.com/zsh-users/zsh-syntax-highlighting.git

  cd "$LAST_PWD"
}

zsh_plugins_update() {
  local LAST_PWD=$(pwd)

  cd ~/.zsh/plugins/

  for d in *; do
    cd "$d" && git pull && cd ..
  done

  cd "$LAST_PWD"
}
