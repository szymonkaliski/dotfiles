let g:grepper = {}
let g:grepper.highlight = 1
let g:grepper.prompt = 0
let g:grepper.stop = 1000
let g:grepper.tools = [ 'rg', 'ag', 'git', 'ack', 'grep' ]

let g:grepper.rg = {
      \ 'grepprg':    'rg --smart-case -H --no-heading --vimgrep',
      \ 'grepformat': '%f:%l:%c:%m',
      \ 'escape':     '\^$.*+?()[]{}|'
      \ }

" grep from commandline
command! -nargs=+ Grep :GrepperRg <args>

" [g]rep
nnoremap <leader>g :Grep<space>
xmap     <leader>g <plug>(GrepperOperator)

" [g]o [l]ook (everything else is taken)
nmap gl <plug>(GrepperOperator)
xmap gl <plug>(GrepperOperator)
