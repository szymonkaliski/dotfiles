let g:airline#extensions#ale#enabled = 1
let g:ale_statusline_format = ['E: %d', 'W: %d', '']
let g:ale_echo_msg_format = '%linter%: %s'

let g:ale_set_signs = 0
" let g:ale_sign_error = '・'
" let g:ale_sign_warning = '・'

nmap <silent> [a <Plug>(ale_previous_wrap)
nmap <silent> ]a <Plug>(ale_next_wrap)
nnoremap coa :ALEToggle<cr>:echom g:ale_enabled ? "ALE: Enabled" : "ALE: Disabled"<cr>
