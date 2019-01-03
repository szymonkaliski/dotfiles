let g:quickhl_manual_colors = [
      \ 'gui=bold ctermbg=' . g:base16_cterm0D . ' ctermfg=0',
      \ 'gui=bold ctermbg=' . g:base16_cterm0E . ' ctermfg=0',
      \ 'gui=bold ctermbg=' . g:base16_cterm0C . ' ctermfg=0',
      \ 'gui=bold ctermbg=' . g:base16_cterm0A . ' ctermfg=0',
      \ 'gui=bold ctermbg=' . g:base16_cterm0B . ' ctermfg=0',
      \ 'gui=bold ctermbg=' . g:base16_cterm08 . ' ctermfg=0'
      \ ]

nmap <leader>h <Plug>(quickhl-manual-this)
xmap <leader>h <Plug>(quickhl-manual-this)
nmap <leader>H <Plug>(quickhl-manual-reset)
xmap <leader>H <Plug>(quickhl-manual-reset)
