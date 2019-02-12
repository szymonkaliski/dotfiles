nnoremap <buffer> <silent> u :<c-u>Dirvish %:h:h<cr>
nnoremap <buffer> <silent> e :<c-u>call dirvish#open('edit', 0)<cr>

nnoremap <buffer> <silent> <c-f> q
nnoremap <buffer> <silent> <esc> q

" nnoremap <buffer> <silent> <c-p> :FZFDirFiles<cr>
nnoremap <buffer> <silent> <c-p> :FZFFiles<cr>

nnoremap <buffer> - <nop>
