# history
setopt bang_hist              # treat the '!' character specially during expansion
setopt hist_expire_dups_first # expire duplicate entries first when trimming history
setopt hist_find_no_dups      # do not display a line previously found
setopt hist_ignore_all_dups   # ignore all double commands in history
setopt hist_ignore_dups       # don't record an entry that was just recorded again
setopt hist_ignore_space      # don't add commands to history that start with space
setopt hist_reduce_blanks     # reduce blanks in history
setopt hist_save_no_dups      # don't write duplicate entries in the history file
setopt histverify             # when using ! cmds, confirm first
setopt inc_append_history     # write to the history file immediately, not when the shell exits
setopt share_history          # share history between all sessions

# other
setopt auto_param_slash       # add trailing slash to directory names
setopt auto_remove_slash      # remove trailing slash when appropriate
setopt combining_chars        # fixes for completion and UTF-8
setopt complete_in_word       # completion "inside" word
setopt correct                # correct only commands
setopt list_types             # show ls -F style marks in file completion
setopt no_beep                # no beep on zle errors
setopt no_cdable_vars         # who wants to cd apache?
setopt no_check_jobs          # don't report on bg processes when exiting
setopt no_hup                 # and don't kill them
setopt no_list_beep           # no beep sound when complete list displayed
setopt prompt_subst           # dynamic prompt changes
