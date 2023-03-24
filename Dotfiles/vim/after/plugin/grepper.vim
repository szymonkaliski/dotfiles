let g:grepper = {}
let g:grepper.highlight = 1
let g:grepper.prompt = 0
let g:grepper.stop = 1000
let g:grepper.tools = [ 'rg', 'ag', 'git', 'ack', 'grep' ]

" sort-files is a (hopefully temporary) hack: https://github.com/mhinz/vim-grepper/issues/244
let g:grepper.rg = {
      \ 'grepprg':    'rg --smart-case -H --no-heading --vimgrep --sort-files $* .',
      \ 'grepformat': '%f:%l:%c:%m',
      \ 'escape':     '\^$.*+?()[]{}|'
      \ }

" grep from commandline
command! -nargs=+ Grep :GrepperRg <q-args>

" [g]rep
nnoremap <leader>g :Grep<space>
xmap     <leader>g <plug>(GrepperOperator)

" [g]o [l]ook (everything else is taken)
nmap gl <plug>(GrepperOperator)
xmap gl <plug>(GrepperOperator)
