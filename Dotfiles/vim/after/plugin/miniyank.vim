if !has('nvim') || (has('vim') && !has('patch-8.0.1394'))
  finish
end

let g:miniyank_maxitems = 100
let g:miniyank_filename = $HOME . '/.miniyank.mpack'

map  p  <Plug>(miniyank-autoput)
map  P  <Plug>(miniyank-autoPut)
nmap gp <Plug>(miniyank-cycle)
nmap gP <Plug>(miniyank-cycleback)
