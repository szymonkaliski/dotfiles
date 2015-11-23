let g:easy_align_delimiters = {
      \   '/': {
      \     'pattern':         '//\+\|/\*\|\*/',
      \     'delimiter_align': 'l',
      \     'ignore_groups':   [ '!Comment' ]
      \   },
      \   ';': {
      \     'pattern':         ';',
      \     'delimiter_align': 'l',
      \     'ignore_groups':   [ '!Comment' ]
      \   },
      \   '(': {
      \     'pattern':         '(',
      \     'delimiter_align': 'l',
      \     'right_margin':    0
      \   },
      \   ']': {
      \     'pattern':         '[[\]]',
      \     'left_margin':     0,
      \     'right_margin':    0,
      \     'stick_to_left':   0
      \   }
      \ }

let g:easy_align_bypass_fold = 1

xmap <leader>a =gv<Plug>(EasyAlign)
nmap ga        <Plug>(EasyAlign)
