au BufNewFile,BufRead *.ts  let b:tsx_ext_found = 0 | setlocal filetype=typescript
au BufNewFile,BufRead *.tsx let b:tsx_ext_found = 1 | setlocal filetype=typescriptreact

" fix for vim-jsx-typescript issue with JSX-like comments being applied to the
" whole file: https://github.com/peitalin/vim-jsx-typescript/issues/14 also
" look at commentary.vim and the implementation of `commentstring#table` to
" have the whole story
au FileType typescriptreact setlocal commentstring=//\ %s
