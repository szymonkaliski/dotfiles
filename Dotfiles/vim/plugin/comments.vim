augroup comments_plugin
  au!

  au CursorMoved *.js,*.jsx call <sid>set_comment_string_js()
augroup END

function! s:set_comment_string_js()
  let stack = map(synstack(line('.'), col('.')), "synIDattr(synIDtrans(v:val), 'name')")
  let cstr  = &commentstring

  for id in stack
    if id[0:1] ==# 'js'
      let cstr='//%s'
    endif
    if id[0:2] ==# 'jsx'
      let cstr='{/*%s*/}'
    endif
  endfor

  let &commentstring = cstr
endfunction

