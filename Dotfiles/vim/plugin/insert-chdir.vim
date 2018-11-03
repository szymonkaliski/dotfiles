" set autchdir on insert for relative paths completion
augroup instert_chdir
  au!

  au InsertEnter * let save_cwd=getcwd() | set autochdir
  au InsertLeave * set noautochdir | execute 'cd' fnameescape(save_cwd)
augroup END
