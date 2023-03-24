augroup coc_load
  au!

  au User coc.nvim call <sid>coc_load()
augroup END

function! s:coc_load()
  " sign define CocCurrentLine linehl=CocMenuSel
  sign define CocCurrentLine linehl=CocLineSign
  sign define CocListCurrent linehl=CocLineSign

  let g:coc_global_extensions = [
        \ 'coc-css',
        \ 'coc-highlight',
        \ 'coc-html',
        \ 'coc-json',
        \ 'coc-pairs',
        \ 'coc-prettier',
        \ 'coc-rust-analyzer',
        \ 'coc-sourcekit',
        \ 'coc-tsserver',
        \ 'coc-vimlsp',
        \ 'coc-yaml'
        \ ]

  function! s:has_floating_window() abort
    return (exists('##MenuPopupChanged') || exists('##CompleteChanged')) && exists('*nvim_open_win')
  endfunction

  call coc#config('coc.preferences', { 'hoverTarget': <sid>has_floating_window() ? 'float' : 'echo' })
  call coc#config('suggest', { 'floatEnable': <sid>has_floating_window() })
  call coc#config('signature', { 'target': <sid>has_floating_window() ? 'float' : 'echo' })
  call coc#config('hover', { 'target': <sid>has_floating_window() ? 'float' : 'echo' })

  inoremap <silent><expr> <tab>
        \ coc#pum#visible() ? coc#pum#next(1):
        \ <sid>check_backspace() ? "\<tab>" :
        \ coc#refresh()

  inoremap <expr><s-tab> coc#pum#visible() ? coc#pum#prev(1) : "\<c-h>"

  inoremap <silent><expr> <cr>
        \ coc#pum#visible() ? coc#pum#confirm()
        \ : "\<C-g>u\<CR>\<c-r>=coc#on_enter()\<CR>"

  nnoremap <silent> <leader>ch :call <sid>do_hover()<cr>

  nnoremap <silent> <leader>ca :call CocActionAsync('codeAction')<cr>
  nnoremap <silent> <leader>cn :call CocActionAsync('rename')<cr>

  nnoremap <silent> <leader>cr :call CocActionAsync('jumpReferences')<cr>
  nnoremap <silent> <leader>cd :call CocActionAsync('jumpDefinition')<cr>
  nnoremap <silent> <leader>cD :call CocActionAsync('jumpDefinition', 'vsplit')<cr>

  nnoremap <silent>gd :call CocActionAsync('jumpDefinition')<cr>
  nnoremap <silent>gD :call CocActionAsync('jumpDefinition', 'vsplit')<cr>

  nnoremap <silent> <leader>p :call CocActionAsync('format')<cr>
  xnoremap <silent> <leader>p <Plug>(coc-format-selected)

  nmap <silent> [a <Plug>(coc-diagnostic-prev)
  nmap <silent> ]a <Plug>(coc-diagnostic-next)

  " i/a function
  xmap if <Plug>(coc-funcobj-i)
  omap if <Plug>(coc-funcobj-i)
  xmap af <Plug>(coc-funcobj-a)
  omap af <Plug>(coc-funcobj-a)

  " no underlines
  hi clear CocUnderline

  function! s:check_backspace() abort
    let col = col('.') - 1
    return !col || getline('.')[col - 1]  =~# '\s'
  endfunction

  function! s:do_hover()
    if (index(['vim', 'help'], &filetype) >= 0)
      execute 'h ' . expand('<cword>')
    else
      call CocActionAsync('doHover')
    endif
  endfunction

  function! s:do_highlight()
    if (&ft == 'text' || &ft == 'markdown' || &ft == 'dirvish')
      return
    endif

    silent call CocActionAsync('highlight')
  endfunction

  function! s:coc_update_lightline()
    " update lightline only if we have statusline visible
    if &laststatus > 0
      call lightline#update()
    endif
  endfunction

  augroup coc_plugin
    au!

    au User CocJumpPlaceholder  call CocActionAsync('showSignatureHelp')
    au CursorHold *             call <sid>do_highlight()

    au User CocDiagnosticChange call <sid>coc_update_lightline()
    au User CocStatusChange     call <sid>coc_update_lightline()
  augroup ENDD
  endfunction
