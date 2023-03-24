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

# quickly duplicate things
dup() {
  for file in "$@"; do
    cp -f "$file" "${file}.dup"
  done
}

# rename files
name() {
  local newname="$1"
  vared -c -p "rename to: " newname
  command mv "$1" "$newname"
}

# simple httpserver
serve() {
  local port="3000"

  if [ "$#" -ne 0 ]; then
    port="$@"
  fi

  if hash serve-http 2> /dev/null; then
    serve-http -p $port -public
  elif hash caddy 2> /dev/null; then
    caddy file-server -browse -listen :$port
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
if hash fd 2> /dev/null; then
  alias fn="$(which fd) --hidden --follow --exclude .git"

  alias fd="fn --type directory"
  alias ff="fn --type file"
# else
#   fn() { find . -iname "*$@*"         2>/dev/null }
#   fd() { find . -iname "*$@*" -type d 2>/dev/null }
#   ff() { find . -iname "*$@*" -type f 2>/dev/null }
fi

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
zsh-recompile() {
  autoload -Uz zrecompile

  [ -f ~/.zshrc ] && zrecompile -p ~/.zshrc
  [ -f ~/.zcompdump ] && zrecompile -p ~/.zcompdump

  for f in ~/.zsh/*.zsh; do
    zrecompile -p $f
  done
}

# load zmv only when needed
mmv() {
  autoload -Uz zmv
  noglob zmv -W $@
}

# re-run command if failed
retry() {
  until $@; do
    sleep 1
    echo -e "\n[$(date +'%T')] $(tput setaf 1)retrying:$(tput sgr0) $@\n"
  done
}

# re-run command every second
repeatedly() {
  while true; do
    echo -e "[$(date +'%T')] $(tput setaf 1)running:$(tput sgr0) $@\n"
    $@
    echo
    sleep 1
  done
}

timer() {
  if [ "$#" -eq 0 ]; then
    # count up if no time given
    stopwatch
  else
    # count down if time given
    local start=$(($(date +%s) + $(seconds $1)));

    while [ "$start" -ge $(date +%s) ]; do
      echo -ne "$(date -u --date @$(($start - $(date +%s))) +%H:%M:%S)\r";
      sleep 0.1
    done
  fi
}

stopwatch() {
  local start=$(date +%s);

  while true; do
    echo -ne "$(date -u --date @$(($(date +%s) - $start)) +%H:%M:%S)\r";
    sleep 0.1
  done
}

# faster yt-dl --batch-file
parallel-yt-dlp() {
  cat "$@" | sort | uniq | parallel -u -j 16 --progress --eta "yt-dlp --newline {}"
}

# useful if there's a lot of files, but they download slowly
parallel-wget() {
  cat "$@" | sort | uniq | parallel -u -j 16 --progress --eta "wget -c {}"
}

# check if website is up
is-up() {
  if curl --silent https://downforeveryoneorjustme.com/"$1" | grep -q "just you"; then
    echo "$1 is up"
  else
    echo "$1 is down"
  fi
}

alias is-down="is-up"

# nnn
n() {
  export NNN_TMPFILE=${XDG_CONFIG_HOME:-$HOME/.config}/nnn/.lastd
  export NNN_FCOLORS="0b0304020f0e050740020a08" # man nnn
  export NNN_COLORS="7"

  nnn "$@"

  if [ -f $NNN_TMPFILE ]; then
    source $NNN_TMPFILE
    /bin/rm $NNN_TMPFILE
  fi
}

# pretty print CSV
catcsv() {
  column -s , -t < "$@" | less -S
}

# archive stuff by year
archive() {
  if [ "$#" -eq 0 ]; then
    echo "pass file/folder as argument"
  else
    mkdir -p Archive
    mv "$@" "Archive/$(date +%Y) - $@"
  fi
}

# watchexec with nicer format and default options
watchexec() {
  cmd="echo \"$(tput setaf 8)[$(date +'%Y-%m-%d %T')]$(tput sgr0) $@\" ; $@ ; echo"
  /usr/local/bin/watchexec --project-origin . --restart $cmd
}
