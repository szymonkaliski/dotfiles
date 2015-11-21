# options
setopt histverify             # when using ! cmds, confirm first
setopt hist_ignore_all_dups   # ignore all double commands in history
setopt hist_ignore_space      # don't add commands to history that start with space
setopt hist_reduce_blanks     # reduce blanks in history
setopt share_history          # share history among zsh sessions
setopt no_check_jobs          # don't report on bg processes when exiting
setopt no_hup                 # and don't kill them
setopt correct                # correct only commands
setopt complete_in_word       # completion "inside" word
setopt auto_param_slash       # add trailing slash to directory names
setopt auto_remove_slash      # remove trailing slash when appropriate
setopt list_types             # show ls -F style marks in file completion
setopt no_cdable_vars         # who wants to cd apache?
setopt prompt_subst           # dynamic prompt changes
setopt combining_chars        # fixes for completion and UTF-8
setopt no_list_beep           # no beep sound when complete list displayed
setopt no_beep                # no beep on zle errors

