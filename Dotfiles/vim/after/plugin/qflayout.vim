function! QFFormatter()
  let list = vim_addon_qf_layout#GetList()

  for l in list
    let l.filename = bufname(l.bufnr)
    let l.text     = trim(l.text)
  endfor

  let max_filename_len = max(map(copy(list), 'len(v:val.filename)' ))
  let max_lnum_len     = max(map(copy(list), 'len(v:val.lnum)'))

  let max_filename_len = min([120, max_filename_len + 1])

  call append('0', map(list, 'printf("%-' . max_filename_len . 'S|%' . max_lnum_len . 'S| %s", v:val.filename, v:val.lnum, v:val.text)'))
endfunction

let g:vim_addon_qf_layout = {}
let g:vim_addon_qf_layout.quickfix_formatters = [ 'QFFormatter', 'NOP' ]
let g:vim_addon_qf_layout.lhs_cycle = '<buffer> \v'

" automatically layout the quickfix list on entry -- this fixes re-layouting
" when running grep for the second time
augroup automatic_qf_layout
  au!

  au BufWinEnter quickfix call vim_addon_qf_layout#ReformatWith('QFFormatter')
augroup END

