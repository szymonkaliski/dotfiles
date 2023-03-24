# z with fzf
j() {
  if [[ -z "$*" ]]; then
    cd "$(_z -l 2>&1 | sed -n 's/^[ 0-9.,]*//p' | fzf --prompt='jump > ')"
  else
    _z "$@"
  fi
}

# edit files in editor
fe() {
  local preview="bat --style=plain --color=always --theme=base16-256 --line-range=:200 {}"

  fzf --multi --select-1 --exit-0 --query="$1" --prompt="files > " --preview=$preview | tr "\n" "\0" | xargs -0 -o v
}

# open file
fo() {
  open $(fzf --select-1 --exit-0 --query="$1" --prompt="open > ")
}

# cd to directory
fcd() {
  local preview="tree -aC --dirsfirst {}"
  local dir=""

  if hash fd 2> /dev/null; then
    dir="$(fd --type d | fzf --select-1 --exit-0 --query="$1" --prompt='dir > ' --preview=$preview)"
  else
    dir="$(find ${1:-*} -path '*/\.*' -prune -o -type d -print 2> /dev/null | fzf --select-1 --exit-0 --query="$1" --prompt='dir > ' --preview=$preview)"
  fi

  [ -n "$dir" ] && cd "$dir"
}

# search through history
fh() {
  print -z $(fc -l 1 | fzf --tac --query="$1" --prompt="history > " | sed 's/ *[0-9]* *//')
}

# kill process
fkill() {
  ps -ef | sed 1d | fzf --multi --query="$1" --prompt="kill > " | awk '{ print $2 }' | xargs kill -${1:-9}
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
