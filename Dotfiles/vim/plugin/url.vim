if !has('mac')
  finish
end

function! s:HandleURL(visual)
  let l:uri = ''

  if a:visual
    let [l:lnum1, l:col1] = getpos("'<")[1:2]
    let [l:lnum2, l:col2] = getpos("'>")[1:2]
    let l:lines = getline(l:lnum1, l:lnum2)
    let l:lines[-1] = l:lines[-1][: l:col2 - (&selection == 'inclusive' ? 1 : 2)]
    let l:lines[0] = l:lines[0][l:col1 - 1:]

    let l:uri = join(l:lines, '\n')
  else
    let l:uri = matchstr(getline('.'), '[a-z]*:\/\/[^ >,;]*')
  endif

  if l:uri != ''
    let l:uri = escape(l:uri, '#%!')

    silent exe '!open "' . l:uri . '"'
    redraw!

    echo 'Opening: ' . l:uri
  else
    echo "Can't find URI"
  endif
endfunction

map <Plug>HandleURLNormal :call <sid>HandleURL(0)<cr>:call repeat#set("\<Plug>HandleURLNormal")<cr>
map <Plug>HandleURLVisual :call <sid>HandleURL(1)<cr>:call repeat#set("\<Plug>HandleURLVisual")<cr>

nmap gx <Plug>HandleURLNormal
xmap gx <Plug>HandleURLVisual
