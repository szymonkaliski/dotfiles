if [ -d /usr/local/share/zsh/site-functions ]; then
  export FPATH="/usr/local/share/zsh/site-functions:$FPATH"
fi

if [ -d /usr/local/share/zsh-completions ]; then
  export FPATH="/usr/local/share/zsh-completions:$FPATH"
fi

if [ -d ~/.zsh/completions ]; then
  export FPATH="~/.zsh/completions:$FPATH"
fi

typeset -gU fpath     # clean fpaths
autoload -Uz compinit # load completions
compinit -C

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

# lowercase letters also match uppercase letters
zstyle ":completion:*" matcher-list "" "m:{[:lower:][:upper:]}={[:upper:][:lower:]}" "+l:|?=** r:|?=**"

# auto rehash commands
zstyle ":completion:*" rehash true

# prevent from eating spaces after completion when inserting | &
if [[ -o interactive ]]; then
  ZLE_REMOVE_SUFFIX_CHARS=$' \n\t;'
fi

# custom completions

function _comp_tm() {
  IFS=$'\n'
  for t in $(tmux ls 2> /dev/null | cut -d: -f1); do
    reply+="$t"
  done
}

function _comp_p() {
  IFS=$'\n'
  for line in $(p --ls); do
    reply+="$line"
  done
}

function _comp_base16() {
  IFS=$'\n'
  for c in $(find $BASE16_SHELL/scripts/ -type f | sed 's/^.*base16-\(.*\).sh/\1/' | cut -d '.' -f1); do
    reply+="$c"
  done
}

compctl -K _comp_base16 base16
compctl -K _comp_p      p
compctl -K _comp_tm     tm

compctl -g '*.tar.bz2 *.tar.gz *.bz2 *.gz *.jar *.rar *.tar *.tbz2 *.tgz *.zip *.Z' + -g '*(-/)' extract
compctl -f -x "c[-1,retry]" -c -- retry
compctl -f -x "c[-1,repeatedly]" -c -- repeatedly

# make `open` aware of /Applications
compctl -f \
  -x 'p[2]' \
  -s "$(/bin/ls -d1 /Applications/*.app | sed 's|^.*/\([^/]*\)\.app.*|\\1|;s/ /\\\\ /g')" \
  -- open

