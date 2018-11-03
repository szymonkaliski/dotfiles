if !has('nvim')
  finish
end

tnoremap <esc> <c-\><c-n>

tnoremap <silent> <c-h> <c-\><c-n>:TmuxNavigateLeft<cr>
tnoremap <silent> <c-j> <c-\><c-n>:TmuxNavigateDown<cr>
tnoremap <silent> <c-k> <c-\><c-n>:TmuxNavigateUp<cr>
tnoremap <silent> <c-l> <c-\><c-n>:TmuxNavigateRight<cr>

let g:terminal_scrollback_buffer_size = 5000

augroup nvim_term
  au!

  au BufEnter term://* startinsert
augroup END
