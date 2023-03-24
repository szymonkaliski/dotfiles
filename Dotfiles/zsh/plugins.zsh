# z for better jumps
load_z() {
  if [ ! -f ~/.zsh/plugins/z/z.sh ]; then
    exit
  fi

  source ~/.zsh/plugins/z/z.sh
}

# better pairs
load_autopair() {
  if [ ! -f ~/.zsh/plugins/zsh-autopair/autopair.zsh ]; then
    exit
  fi

  source ~/.zsh/plugins/zsh-autopair/autopair.zsh
}

# nvm for node versions
load_nvm() {
  if [ ! -f ~/.zsh/plugins/zsh-nvm/zsh-nvm.plugin.zsh ]; then
    exit
  fi

  export NVM_NO_USE=true    # don't load node by default - we have quicker PATH hack for that
  export NVM_LAZY_LOAD=true # don't load nvm if it's not used

  source ~/.zsh/plugins/zsh-nvm/zsh-nvm.plugin.zsh
}

# live command highlighting like fish, but faster than zsh-syntax-highlight
load_syntax_highlight() {
  if [ ! -f ~/.zsh/plugins/fast-syntax-highlighting/fast-syntax-highlighting.plugin.zsh ]; then
    exit
  fi

  source ~/.zsh/plugins/fast-syntax-highlighting/fast-syntax-highlighting.plugin.zsh

  FAST_HIGHLIGHT_STYLES[precommand]='fg=magenta'
  FAST_HIGHLIGHT_STYLES[commandseparator]='fg=yellow'
  FAST_HIGHLIGHT_STYLES[path]='fg=default'
  FAST_HIGHLIGHT_STYLES[path-to-dir]='fg=default'
  FAST_HIGHLIGHT_STYLES[single-hyphen-option]='fg=yellow'
  FAST_HIGHLIGHT_STYLES[double-hyphen-option]='fg=yellow'
  FAST_HIGHLIGHT_STYLES[back-quoted-argument]='fg=magenta'
  FAST_HIGHLIGHT_STYLES[single-quoted-argument]='fg=red'
  FAST_HIGHLIGHT_STYLES[double-quoted-argument]='fg=red'
  FAST_HIGHLIGHT_STYLES[variable]='fg=red'
  FAST_HIGHLIGHT_STYLES[global-alias]='fg=magenta'

  FAST_HIGHLIGHT[no_check_paths]=1
  FAST_HIGHLIGHT[use_brackets]=1
  FAST_HIGHLIGHT[use_async]=1
}

# gitstatus
load_gitstatus() {
  if [ !-f ~/.zsh/plugins/gitstatus/gitstatus.plugin.zsh ]; then
    exit
  fi

  source ~/.zsh/plugins/gitstatus/gitstatus.plugin.zsh
  gitstatus_stop "GITSTATUS" && gitstatus_start -s -1 -u -1 -c -1 -d -1 -t 16 "GITSTATUS"

  setup_git_prompt_status
}

# "plugin manager"
zsh_plugins_install() {
  mkdir -p ~/.zsh/plugins/
  pushd ~/.zsh/plugins/ > /dev/null

  git clone -b zsh-flock git://github.com/mafredri/z
  git clone git://github.com/chriskempson/base16-shell
  git clone git://github.com/hlissner/zsh-autopair
  git clone git://github.com/lukechilds/zsh-nvm
  git clone git://github.com/romkatv/gitstatus
  git clone git://github.com/zdharma-continuum/fast-syntax-highlighting
  git clone https://github.com/romkatv/zsh-defer

  popd > /dev/null
}

zsh_plugins_update() {
  pushd ~/.zsh/plugins/ > /dev/null

  for d in *; do
    pushd "$d" > /dev/null
    git pull
    popd > /dev/null
  done

  popd > /dev/null
}

# (deferred) loading
load_z # I often want to jump somewhere immediately when opening a shell
zsh-defer -t 0.5 load_autopair
zsh-defer -t 0.5 load_syntax_highlight
zsh-defer -t 1.0 load_gitstatus
zsh-defer -t 1.0 load_nvm

