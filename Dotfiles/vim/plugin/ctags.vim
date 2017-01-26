augroup async_ctags
  au!

  au VimEnter *.js,*.jsx Ctags
  au BufWritePost *.js,*.jsx Ctags
augroup END

command! Ctags call ctags#run_async()

