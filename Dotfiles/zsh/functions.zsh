# tmux
tm() {
  local attach=""
  local title=""

  if [ "$#" -ne 0 ]; then
    title=$1
  else
    if [[ $PWD != $HOME ]]; then
      local dir=""
      if [[ ${PWD##*/} == "Code" ]]; then
        local dirname="$(dirname "$PWD")"
        dir=$(basename "$dirname")
      else
        dir=${PWD##*/}
      fi

      title="$(echo $dir | tr "[:upper:]" "[:lower:]" | sed "s/[\ |\.]/\-/g")"
    else
      title="home"
    fi
  fi

  tmux has-session -t $title > /dev/null 2>&1

  if [ $? -eq 0 ]; then
    attach=$title
  else
    for session in $(tmux ls 2>/dev/null | cut -d: -f1); do
      if [[ $session =~ $title  ]]; then
        attach=$session
        break
      fi
    done
  fi

  if [[ $attach != "" ]]; then
    if [ -z $TMUX ]; then
      tmux attach -t $attach
    else
      tmux switch-client -t $attach
    fi
  else
    if [ -z $TMUX ]; then
      tmux new -s $title
    else
      TMUX=$(tmux new-session -d -s $title)
      tmux switch-client -t $title
    fi
  fi
}
compctl -s "$(tmux ls 2> /dev/null | cut -d: -f1)" tm

# use local npm binaries
npm-exec() {
  PATH="$(npm bin):$PATH" "$@"
}

# sudo previous command
sudothat() {
  echo -e "$(tput setaf 1)sudo$(tput sgr0) → $(fc -ln -1)"
  eval "sudo $(fc -ln -1)"
}

# grep with vim
vigrep() {
  $EDITOR -c "call GrepHandler(\"$@\")"
}

# history
h() {
  if [ "$#" -eq 0 ]; then
    history
  else
    history 0 | egrep -i --color=auto $@
  fi
}

# go up 'n' directories
up() {
  for updirs in $(seq ${1:-1}); do
    cd ..
  done
}

# mkdir & cd
cdir() {
  if [ ! -d "$@" ]; then
    mkdir -p "$@"
  fi
  cd "$@"
}

# quickly add and remove '.bak' to files
bak() {
  for file in "$@"; do
    if [[ $file =~ "\.bak$" ]]; then
      mv -iv "$file" "$(basename ${file} .bak)"
    else
      mv -iv "$file" "${file}.bak"
    fi
  done
}

# rename files
name() {
  local newname="$1"
  vared -c -p "rename to: " newname
  command mv "$1" "$newname"
}

# simple httpserver
httpserver() {
  local port="3000"

  if [ "$#" -ne 0 ]; then
    port="$@"
  fi

  if hash http-server 2> /dev/null; then
    http-server -p $port -c-1
  else
    local command=""
    if [ "$(uname)" = "Darwin" ]; then
      command="SimpleHTTPServer"
    else
      command="http.server"
    fi

    python -m $command $port
  fi
}

# simple find functions
fn() { find . -iname "*$@*" 2>/dev/null         }
fd() { find . -iname "*$@*" -type d 2>/dev/null }
ff() { find . -iname "*$@*" -type f 2>/dev/null }

# extract archives
extract() {
  if [[ -z "$1" ]]; then
    echo "extracts files based on extensions"
  elif [[ -f $1 ]]; then
    case ${(L)1} in
      *.tar.bz2) tar -jxvf $1  ;;
      *.tar.gz)  tar -zxvf $1  ;;
      *.tar.xz)  tar -xvf $1   ;;
      *.bz2)     bunzip2 $1    ;;
      *.gz)      gunzip $1     ;;
      *.jar)     unzip $1      ;;
      *.rar)     unrar x $1    ;;
      *.tar)     tar -xvf $1   ;;
      *.tbz2)    tar -jxvf $1  ;;
      *.tgz)     tar -zxvf $1  ;;
      *.zip)     unzip $1      ;;
      *.Z)       uncompress $1 ;;
      *)         echo "unable to extract '$1'"
    esac
  else
    echo "file '$1' does not exist!"
  fi
}
compctl -g '*.tar.bz2 *.tar.gz *.bz2 *.gz *.jar *.rar *.tar *.tbz2 *.tgz *.zip *.Z' + -g '*(-/)' extract

# sanitize permissions
sanitize() {
  if [ "$#" -eq 0 ]; then
    local DIR="."
  else
    local DIR="$@"
  fi

  find "$DIR" -type d -print0 | xargs -0 chmod 755
  find "$DIR" -type f -print0 | xargs -0 chmod 644
}

# recompile zsh
recompile() {
  autoload -U zrecompile

  [ -f ~/.zshrc ]             && zrecompile -q -p ~/.zshrc     > /dev/null 2>&1
  [ -f ~/.zcompdump ]         && zrecompile -q -p ~/.zcompdump > /dev/null 2>&1
  [ -f ~/.zshrc.zwc.old ]     && rm -f ~/.zshrc.zwc.old        > /dev/null 2>&1
  [ -f ~/.zcompdump.zwc.old ] && rm -f ~/.zcompdump.zwc.old    > /dev/null 2>&1
}

# load zmv only when needed
mmv() { autoload -U zmv; noglob zmv -W $@ }
