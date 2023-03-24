let g:quickhl_manual_colors = [
      \ 'guibg=#' . g:base16_gui0D . ' guifg=#' . g:base16_gui00 . ' ctermbg=' . g:base16_cterm0D . ' ctermfg=' . g:base16_cterm00,
      \ 'guibg=#' . g:base16_gui0E . ' guifg=#' . g:base16_gui00 . ' ctermbg=' . g:base16_cterm0E . ' ctermfg=' . g:base16_cterm00,
      \ 'guibg=#' . g:base16_gui0C . ' guifg=#' . g:base16_gui00 . ' ctermbg=' . g:base16_cterm0C . ' ctermfg=' . g:base16_cterm00,
      \ 'guibg=#' . g:base16_gui0A . ' guifg=#' . g:base16_gui00 . ' ctermbg=' . g:base16_cterm0A . ' ctermfg=' . g:base16_cterm00,
      \ 'guibg=#' . g:base16_gui0B . ' guifg=#' . g:base16_gui00 . ' ctermbg=' . g:base16_cterm0B . ' ctermfg=' . g:base16_cterm00,
      \ 'guibg=#' . g:base16_gui08 . ' guifg=#' . g:base16_gui00 . ' ctermbg=' . g:base16_cterm08 . ' ctermfg=' . g:base16_cterm00
      \ ]

nmap <leader>h <Plug>(quickhl-manual-this)
xmap <leader>h <Plug>(quickhl-manual-this)
nmap <leader>H <Plug>(quickhl-manual-reset)
xmap <leader>H <Plug>(quickhl-manual-reset)
