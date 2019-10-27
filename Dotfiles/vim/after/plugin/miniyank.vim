if !(has('nvim') || (has('vim') && has('lua')))
  finish
end

" echo 'miniyank enabled'

let g:miniyank_maxitems = 100
let g:miniyank_delete_maxlines = 1000
let g:miniyank_filename = $HOME . '/.miniyank.mpack'

map  p  <Plug>(miniyank-autoput)
map  P  <Plug>(miniyank-autoPut)
nmap gp <Plug>(miniyank-cycle)
nmap gP <Plug>(miniyank-cycleback)
