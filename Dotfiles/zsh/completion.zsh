if [ -d /usr/local/share/zsh/site-functions ]; then
  export FPATH="/usr/local/share/zsh/site-functions:$FPATH"
fi

if [ -d /usr/local/share/zsh-completions ]; then
  export FPATH="/usr/local/share/zsh-completions:$FPATH"
fi

if [ -d ~/.zsh/completion ]; then
  export FPATH="~/.zsh/completion:$FPATH"
fi

typeset -gU fpath     # clean fpaths
autoload -Uz compinit # load completions
compinit -C           # without securiy checks

# complete with dots, useful on slow systems
expand-or-complete-with-dots() {
  echo -n "$(tput setaf 6)...$(tput sgr0)"
  zle expand-or-complete
  zle redisplay
}
zle -N expand-or-complete-with-dots
bindkey "^I" expand-or-complete-with-dots

# speed up completion by avoiding partial globs.
zstyle ':completion:*' accept-exact '*(N)'
zstyle ':completion:*' accept-exact-dirs true

# use completion cache
zstyle ":completion:*" use-cache true

# colors in completion
zstyle ":completion:*" list-colors ${(s.:.)LS_COLORS}

# separate directories from files.
zstyle ':completion:*' list-dirs-first true

# complete with menu
setopt menucomplete
zstyle ":completion:*" menu select=long-list select=1

# list of completers to use
zstyle ":completion:*" completer _expand _complete _approximate

# remove the trailing slashes
zstyle ":completion:*" squeeze-slashes true

# complete mosh/ssh/scp
zstyle -e ':completion:*:(mosh|ssh|scp):*' hosts 'reply=(
  ${=${${${${(@M)${(f)"$(<~/.ssh/config)"}:#Host *}#Host }:#*\**}:#*\?*}}
)'

# ignore completions for commands that we dont have
zstyle ":completion:*" ignored-patterns "_*"

# auto rehash commands
zstyle ":completion:*" rehash true

# prevent from eating spaces after completion when inserting | &
if [[ -o interactive ]]; then
  ZLE_REMOVE_SUFFIX_CHARS=$' \n\t;'
fi

