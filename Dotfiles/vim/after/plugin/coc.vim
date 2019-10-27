let g:coc_global_extensions = [
      \ 'coc-css',
      \ 'coc-highlight',
      \ 'coc-html',
      \ 'coc-json',
      \ 'coc-pairs',
      \ 'coc-rls',
      \ 'coc-snippets',
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

inoremap <silent><expr> <tab>
      \ pumvisible() ? "\<c-n>" :
      \ <sid>check_backspace() ? "\<tab>" :
      \ coc#refresh()

" inoremap <silent><expr> <tab>
"       \ pumvisible() ? coc#_select_confirm() :
"       \ coc#expandableOrJumpable() ? "\<c-r>=coc#rpc#request('doKeymap', ['snippets-expand-jump',''])\<cr>" :
"       \ <SID>check_backspace() ? "\<tab>" :
"       \ coc#refresh()

inoremap <silent><expr> <s-tab> pumvisible() ? "\<c-p>" : "\<c-h>"
inoremap <silent><expr> <cr>    pumvisible() ? coc#_select_confirm() : "\<c-g>u\<cr>\<c-r>=coc#on_enter()\<cr>"

let g:coc_snippet_next = '<tab>'
let g:coc_snippet_prev = '<s-tab>'

nnoremap <silent> gd :call CocAction('jumpDefinition')<cr>
nnoremap <silent> gn <Plug>(coc-rename)
nnoremap <silent> gh :call <sid>do_hover()<cr>

function! s:check_backspace() abort
  let col = col('.') - 1
  return !col || getline('.')[col - 1]  =~# '\s'
endfunction

function! s:do_hover()
  if (index(['vim', 'help'], &filetype) >= 0)
    execute 'h ' . expand('<cword>')
  else
    call CocAction('doHover')
  endif
endfunction

function! s:do_highlight()
  if (&ft == 'text' || &ft == 'markdown' || &ft == 'taskpaper' || &ft == 'dirvish')
    return
  endif

  silent call CocActionAsync('highlight')
endfunction

augroup coc_plugin
  au!

  au User CocJumpPlaceholder call CocActionAsync('showSignatureHelp')
  au CursorHold * call <sid>do_highlight()
augroup END
