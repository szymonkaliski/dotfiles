let g:gitgutter_eager = 0
let g:gitgutter_escape_grep = 1
let g:gitgutter_map_keys = 0
let g:gitgutter_max_signs = 1000
let g:gitgutter_realtime = 0
let g:gitgutter_signs = 0

function! gitgutter#next_hunk()
  let l:prevline = line('.')

  silent exe 'GitGutterNextHunk'

  if l:prevline == line('.')
    normal gg
    exe 'GitGutterNextHunk'
  endif
endfunction

function! gitgutter#prev_hunk()
  let l:prevline = line('.')

  silent exe 'GitGutterPrevHunk'

  if l:prevline == line('.')
    normal G
    exe 'GitGutterPrevHunk'
  endif
endfunction

nnoremap ]g :call gitgutter#next_hunk()<cr>
nnoremap [g :call gitgutter#prev_hunk()<cr>
