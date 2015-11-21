# z for better jumps
if [ -f ~/.zsh/plugins/z/z.sh ]; then
  source ~/.zsh/plugins/z/z.sh

fi

# bd for better up
if [ -f ~/.zsh/plugins/zsh-bd/bd.zsh ]; then
  source ~/.zsh/plugins/zsh-bd/bd.zsh
fi

plugins_install() {
  local LAST_PWD=$(pwd)

  mkdir -p ~/.zsh/plugins/
  cd ~/.zsh/plugins/

  git clone git://github.com/rupa/z.git
  git clone git://github.com/Tarrasch/zsh-bd
  git clone git://github.com/zsh-users/zsh-syntax-highlighting.git

  cd "$LAST_PWD"
}

plugins_update() {
  local LAST_PWD=$(pwd)

  cd ~/.zsh/plugins/

  for d in *; do
    cd "$d" && git pull && cd ..
  done

  cd "$LAST_PWD"
}
