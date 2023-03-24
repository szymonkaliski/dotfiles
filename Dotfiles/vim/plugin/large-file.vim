" disable syntax for large files

let g:large_file_size = 1024 * 1000

augroup large_file
  au!

  au BufReadPre *
        \  let size=getfsize(expand('<afile>'))
        \| if size > g:large_file_size || size == -2
        \|   set eventignore+=FileType
        \| else
        \|   set eventignore-=FileType
        \| endif
augroup END
