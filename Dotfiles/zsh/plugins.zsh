lazy_load() {
  local names=("${(@s: :)${1}}")

  unalias "${names[@]}"

  source $2 > /dev/null
  shift 2

  $*
}

group_lazy_load() {
  local script

  script=$1

  shift 1

  for cmd in "$@"; do
    alias $cmd="lazy_load \"$*\" $script $cmd"
  done
}

# z for better jumps
if [ -f ~/.zsh/plugins/z/z.sh ]; then
  source ~/.zsh/plugins/z/z.sh
fi

# better pairs
if [ -f ~/.zsh/plugins/zsh-autopair/autopair.zsh ]; then
  source ~/.zsh/plugins/zsh-autopair/autopair.zsh
fi

# nvm for node versions
if [ -f ~/.zsh/plugins/zsh-nvm/zsh-nvm.plugin.zsh ]; then
  export NVM_NO_USE=true # don't load node by default - we have quicker PATH hack for that
  export NVM_LAZY_LOAD=true # don't load nvm if it's not used

  source ~/.zsh/plugins/zsh-nvm/zsh-nvm.plugin.zsh

  # for direnv
  export NODE_VERSIONS=~/.nvm/versions/node/
  export NODE_VERSION_PREFIX=""
fi

# luaver for different lua versions
if hash luaver 2> /dev/null; then
  group_lazy_load "$(which luaver)" lua luarocks luaver
fi

# live command highlighting like fish, but faster than zsh-syntax-highlight
if [ -f ~/.zsh/plugins/fast-syntax-highlighting/fast-syntax-highlighting.plugin.zsh ]; then
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
fi

# gitstatus
if [ -f ~/.zsh/plugins/gitstatus/gitstatus.plugin.zsh ]; then
  source ~/.zsh/plugins/gitstatus/gitstatus.plugin.zsh

  OS="$(uname -s)"
  ARCH="$(uname -m)"
  GITSTATUS_DAEMON=~/.zsh/plugins/gitstatus/bin/gitstatusd-${OS:l}-${ARCH:l}

  if ! gitstatus_check gitstatus; then
    gitstatus_stop gitstatus && gitstatus_start -t 0.1 gitstatus
  fi
fi

# back directories
# if [ -d ~/.zsh/plugins/zsh-bdi/ ]; then
#   if [ ! -f ~/.zsh/completions/_bdi.zsh ]; then
#     ln -s ~/.zsh/plugins/zsh-bdi/_bdi.zsh ~/.zsh/completions/_bdi.zsh
#   fi
#   autoload -Uz ~/.zsh/plugins/zsh-bdi/bdi
# fi

zsh_plugins_install() {
  mkdir -p ~/.zsh/plugins/
  pushd ~/.zsh/plugins/ > /dev/null

  git clone -b zsh-flock git://github.com/mafredri/z
  git clone git://github.com/chriskempson/base16-shell
  git clone git://github.com/hlissner/zsh-autopair
  git clone git://github.com/lukechilds/zsh-nvm
  git clone git://github.com/zdharma/fast-syntax-highlighting
  # git clone https://github.com/einiges/zsh-bdi
  git clone git://github.com/romkatv/gitstatus

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

# tmux plugins

tmux_plugins_install() {
  mkdir -p ~/.tmux/plugins/
  pushd ~/.tmux/plugins > /dev/null

  # git clone git://github.com/tmux-plugins/tmux-continuum
  # git clone git://github.com/tmux-plugins/tmux-resurrect

  popd > /dev/null
}

tmux_plugins_update() {
  pushd ~/.tmux/plugins > /dev/null

  for d in *; do
    pushd "$d" > /dev/null
    git pull
    popd > /dev/null
  done

  popd > /dev/null
}
