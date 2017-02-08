" don't load this for now, not using tags that much
finish

augroup async_ctags
  au!

  au VimEnter,BufWritePost *.js,*.jsx Ctags
augroup END

command! Ctags call ctags#run_async()

