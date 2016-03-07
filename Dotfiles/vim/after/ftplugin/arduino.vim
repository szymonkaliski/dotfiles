setlocal commentstring=//\ %s
setlocal makeprg=arduino\ --verify\ %
setlocal errorformat=%E%f:%*[^:]:,%Z%*[^:]:%l:\ %m
