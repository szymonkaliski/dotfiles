nnoremap <buffer> <silent> u  :<c-u>Dirvish %:h:h<cr>
nnoremap <buffer> <silent> e  :<c-u>call dirvish#open('edit',   0)<cr>

nnoremap <buffer> <silent> gf :<c-u>call dirvish#open('edit',   0)<cr>
nnoremap <buffer> <silent> gF :<c-u>call dirvish#open('vsplit', 0)<cr>

map <buffer> <silent> <c-f> gq
map <buffer> <silent> <esc> gq

" not sure why we have to remap this in dirvish
nnoremap <buffer> <silent> <c-p> :FZFFilesFolders<cr>

nnoremap <buffer> - <nop>

" hide .DS_Store
" silent keepjumps keepmarks keeppatterns g/.DS_Store/d

