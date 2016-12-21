if [ -d /usr/local/share/zsh/site-functions ]; then
  export FPATH="/usr/local/share/zsh/site-functions:$FPATH"
fi

if [ -d /usr/local/share/zsh-completions ]; then
  export FPATH="/usr/local/share/zsh-completions:$FPATH"
fi

if [ -d ~/.zsh/completion ]; then
  export FPATH="~/.zsh/completion:$FPATH"
fi

typeset -gU fpath    # clean fpaths
autoload -z compinit # load completions
compinit -C          # without securiy checks

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

# process names from ps
zstyle ":completion:*:processes" command "ps cx -o pid,user,%cpu,%mem,comm"
zstyle ":completion:*:processes-names" command "ps -aeo comm="

# kill & killall completion colors
zstyle ":completion:*:*:kill:*:processes" list-colors "=(#b) #([0-9]#)*=0=01;31"
zstyle ":completion:*:*:killall:*:processes-names" list-colors "=(#b) #([0-9]#f)*=0=01;31"

# complete with menu
setopt menucomplete
zstyle ":completion:*" menu select=long-list select=1

# list of completers to use
zstyle ":completion:*" completer _expand _complete _approximate

# remove the trailing slash (usefull in ln)
zstyle ":completion:*" squeeze-slashes true

# complete ssh/scp
zstyle ':completion:*:scp:*' tag-order 'hosts:-host hosts:-domain:domain hosts:-ipaddr:IP\ address *'
zstyle ':completion:*:scp:*' group-order users files all-files hosts-domain hosts-host hosts-ipaddr
zstyle ':completion:*:ssh:*' tag-order users 'hosts:-host hosts:-domain:domain hosts:-ipaddr:IP\ address *'
zstyle ':completion:*:ssh:*' group-order hosts-domain hosts-host users hosts-ipaddr

zstyle ':completion:*:(ssh|scp):*:hosts-host' ignored-patterns '*.*' loopback localhost
zstyle ':completion:*:(ssh|scp):*:hosts-domain' ignored-patterns '<->.<->.<->.<->' '^*.*' '*@*'
zstyle ':completion:*:(ssh|scp):*:hosts-ipaddr' ignored-patterns '^<->.<->.<->.<->' '127.0.0.<->'
zstyle ':completion:*:(ssh|scp):*:users' ignored-patterns adm bin daemon halt lp named shutdown sync

zstyle -e ':completion:*:(ssh|scp):*' hosts 'reply=(
  ${=${${(f)"$(cat {/etc/ssh_,~/.ssh/known_}hosts(|2)(N) /dev/null)"}%%[# ]*}//,/ }
  ${=${(f)"$(cat /etc/hosts(|)(N) <<(ypcat hosts 2>/dev/null))"}%%\#*}
  ${=${${${${(@M)${(f)"$(<~/.ssh/config)"}:#Host *}#Host }:#*\**}:#*\?*}}
)'

# ignore completions for commands that we dont have
zstyle ":completion:*:functions" ignored-patterns "_*"

# auto rehash commands
zstyle ":completion:*" rehash true

