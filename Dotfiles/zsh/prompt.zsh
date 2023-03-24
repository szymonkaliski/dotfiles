if [ "$(uname)" = "Darwin" ]; then
  PROMPTCOLOR=blue
else
  PROMPTCOLOR=magenta
fi

if [ "$(whoami)" = "root" ]; then
  PROMPTCOLOR=red
fi

prompt_pwd() {
  print -n "%{$fg[$PROMPTCOLOR]%}"
  print -n "%50<...<%3~"
}

prompt_arrow() {
  # first space here is non-breaking, so we can search for it with tmux easily
  print "%{$reset_color%} > "
}

ZSH_MAIN_PROMPT="$(prompt_arrow)"

git_prompt_status() {
  gitstatus_query -d $PWD "GITSTATUS"

  if [ -z $VCS_STATUS_LOCAL_BRANCH ]; then
    PROMPT='$(prompt_pwd)$ZSH_MAIN_PROMPT'
    zle && zle reset-prompt
    return
  fi

  if [ $VCS_STATUS_HAS_STAGED = 0 ] && [ $VCS_STATUS_HAS_UNSTAGED = 0 ] && [ $VCS_STATUS_HAS_CONFLICTED = 0 ] && [ $VCS_STATUS_HAS_UNTRACKED = 0 ]; then
    branch_color="%{$fg[green]%}"
  else
    branch_color="%{$fg[red]%}"
  fi

  git_branch=" $VCS_STATUS_LOCAL_BRANCH"

  PROMPT='$(prompt_pwd)$branch_color$git_branch$ZSH_MAIN_PROMPT'
  zle && zle reset-prompt
}

setup_git_prompt_status() {
  git_prompt_status

  add-zsh-hook precmd  git_prompt_status
  add-zsh-hook preexec git_prompt_status
}

# single-quote comments are important here!
PROMPT='$(prompt_pwd)$ZSH_MAIN_PROMPT'
PROMPT2='%{$fg[yellow]%}%_%{$reset_color%} > '
SPROMPT="correct "%R" to "%r' ? ([Y]es/[N]o/[E]dit/[A]bort) '

