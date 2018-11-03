if !has('nvim')
  finish
end

let g:miniyank_maxitems = 100

map  p  <Plug>(miniyank-autoput)
map  P  <Plug>(miniyank-autoPut)
nmap gp <Plug>(miniyank-cycle)
