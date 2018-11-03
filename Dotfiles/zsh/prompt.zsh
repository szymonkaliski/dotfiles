if [ "$(uname)" = "Darwin" ]; then
  PROMPTCOLOR=blue
elif [ "$(hostname)" = "Stelis" ]; then
  PROMPTCOLOR=cyan
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

# https://medium.com/@henrebotha/how-to-write-an-asynchronous-zsh-prompt-b53e81720d32
# https://github.com/rswiernik/dotfiles/blob/0d35f288b124e53b126fa2e0977b072e4968e591/.config/rzsh/plugins/prompts.zsh

ZSH_MAIN_PROMPT="$(prompt_arrow)"

git_status() {
  cd "$1"

  if ! git rev-parse --is-inside-work-tree &> /dev/null; then
    prompt_arrow
    exit
  fi

  git_status=$(git status --porcelain)
  git_branch=$(git rev-parse --abbrev-ref HEAD 2> /dev/null) || git_branch=""

  if [ -z $git_status ]; then
    branch_color="%{$fg[green]%}"
  else
    branch_color="%{$fg[red]%}"
  fi

  print -n " $branch_color$git_branch"
  prompt_arrow
}

git_prompt_callback() {
  # on completion set main prompt part, and reset prompt to reload
  ZSH_MAIN_PROMPT="$3"
  zle reset-prompt
}

git_prompt_async() {
  async_job git_prompt_worker git_status "$(pwd)"
}

# run async prompt generation before each command
add-zsh-hook precmd git_prompt_async

# async_init assumed from plugins.zsh
async_start_worker git_prompt_worker -n
async_register_callback git_prompt_worker git_prompt_callback

# single-quote comments are important here!
PROMPT='$(prompt_pwd)$ZSH_MAIN_PROMPT'
PROMPT2='%{$fg[yellow]%}%_%{$reset_color%} > '
SPROMPT="correct "%R" to "%r' ? ([Y]es/[N]o/[E]dit/[A]bort) '
