export FZF_DEFAULT_COMMAND="rg --files --hidden --follow --no-messages"
export FZF_DEFAULT_OPTS="--inline-info --cycle
                         --history=$HOME/.fzfhistory
                         --history-size=1000
                         --tiebreak=end,length
                         --no-bold
                         --color=fg+:007,bg+:018,hl:016,hl+:016
                         --color=prompt:008,marker:008,pointer:008,spinner:018,info:008"

# z with fzf
j() {
  if [[ -z "$*" ]]; then
    cd "$(_z -l 2>&1 | sed -n 's/^[ 0-9.,]*//p' | fzf --tac --prompt='jump > ' --reverse)"
  else
    _z "$@"
  fi
}

# edit files in editor
fe() {
  # local preview="highlight --config-file=$HOME/.highlight/hybrid-bw.theme -q -t 2 --force -O xterm256 {}"
  local preview=""

  fzf --multi --select-1 --exit-0 --query="$1" --prompt="files > " --reverse --preview=$preview | tr "\n" "\0" | xargs -0 -o vim
}

# open file
fo() {
  open $(fzf --select-1 --exit-0 --query="$1" --prompt="open > " --reverse)
}

# cd to directory
fcd() {
  # local preview="tree -aC --dirsfirst {}"
  local preview=""
  local dir=""

  if hash blsd 2> /dev/null; then
    dir="$(blsd | fzf --select-1 --exit-0 --query="$1" --prompt='dir > ' --reverse --preview=$preview)"
  else
    dir="$(find ${1:-*} -path '*/\.*' -prune -o -type d -print 2> /dev/null | fzf --select-1 --exit-0 --query="$1" --prompt='dir > ' --reverse --preview=$preview)"
  fi

  [ -n "$dir" ] && cd "$dir"
}

# search through history
fh() {
  print -z $(fc -l 1 | fzf --tac --no-sort --nth=2.. --reverse --query="$1" --prompt="history > " --reverse | sed 's/ *[0-9]* *//')
}

# kill process
fkill() {
  ps -ef | sed 1d | fzf --multi --query="$1" --prompt="kill > " --reverse | awk '{ print $2 }' | xargs kill -${1:-9}
}

# checkout git commit
fcom() {
  local commits=$(git log --pretty=format:"%h%x09 %cr%x09 %s" --decorate --reverse)
  local commit=$(echo "$commits" | fzf --tac --no-sort --exact)

  if [ ! -z $commit ]; then
    git checkout $(echo "$commit" | cut -d " " -f1)
  fi
}

# checkout git branch (including remote)
fbr() {
  local branches=$(git branch --all | grep -v HEAD)
  local branch=$(echo "$branches" | fzf --delimiter $((2 + $(wc -l <<< "$branches"))))

  git checkout $(echo "$branch" | sed "s/.* //" | sed "s#remotes/[^/]*/##")
}
