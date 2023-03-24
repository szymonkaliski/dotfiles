set viewoptions-=options

augroup persist_view
  au!

  au BufWritePost,BufLeave,WinLeave,TabLeave,VimLeave *
        \  if expand('%') != '' && &buftype !~ 'nofile' && &buftype !~ 'terminal' && &filetype !~ 'fzf'
        \|   mkview
        \| endif
  au BufWinEnter *
        \  if expand('%') != '' && &buftype !~ 'nofile' && &buftype !~ 'terminal' && &filetype !~ 'fzf'
        \|   silent! loadview
        \| endif
augroup END
