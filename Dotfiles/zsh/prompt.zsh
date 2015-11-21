autoload -U vcs_info

zstyle ":vcs_info:*" enable git
zstyle ":vcs_info:*" check-for-changes true
zstyle ":vcs_info:*" stagedstr "%{$fg[red]%}"
zstyle ":vcs_info:*" unstagedstr "%{$fg[red]%}"
zstyle ":vcs_info:*" branchformat "%r"
zstyle ":vcs_info:*" actionformats "%{$fg[green]%}%b %{$fg[yellow]%}%u%c"
zstyle ":vcs_info:*" formats "%{$fg[green]%}%b %{$fg[yellow]%}%u%c"

local VCS='$vcs_info_msg_0_'

if [ "$(uname)" = "Darwin" ]; then
  PROMPTCOLOR=blue
elif [ "$(hostname)" = "Disa" ]; then
  PROMPTCOLOR=yellow
else
  PROMPTCOLOR=magenta
fi

if [ "$(whoami)" = "root" ]; then
  PROMPTCOLOR=red
fi

PROMPT="%{$fg[$PROMPTCOLOR]%}%50<...<%3~%{$reset_color%} $VCS> %{$reset_color%}"
RPROMPT="%(?,,%{$fg[red]%}✕%{$reset_color%})"
PROMPT2="%{$fg[yellow]%}%_%{$reset_color%} > "
SPROMPT="correct '%R' to '%r' ? ([Y]es/[N]o/[E]dit/[A]bort) "

