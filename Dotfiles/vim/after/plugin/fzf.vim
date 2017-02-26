if has('gui')
  finish
endif

function! fzf#buffers_list()
  let l:all = range(0, bufnr('$'))
  let l:list = []

  for l:buffer in l:all
    let l:bufname = bufname(l:buffer)
    if buflisted(l:buffer) && index(l:list, l:bufname) == -1 && strlen(l:bufname) > 1
      call add(l:list, l:bufname)
    endif
  endfor

  return list
endfunction

function! fzf#recent_files()
  return filter(v:oldfiles, 'filereadable(glob(v:val))')
endfunction

function! fzf#buffers_lines()
  let res = []

  for b in filter(range(1, bufnr('$')), 'buflisted(v:val)')
    call extend(res, map(getbufline(b,0,'$'), "b . ':' . (v:key + 1) . ':\t' . v:val "))
  endfor

  return res
endfunction

function! fzf#buffers_lines_open(l)
  let keys = split(a:l, ':')
  exe 'buffer ' . keys[0]
  exe keys[1]
  silent! normal! zozz
endfunction

let s:fzf_default_opt = { 'window': 'enew' }

command! FZFFiles call fzf#run(extend(s:fzf_default_opt, {
      \ 'source':  'rg --files --hidden --follow',
      \ 'sink':    'e',
      \ 'options': '--reverse --multi --exit-0 --prompt="files > "'
      \ }))

command! FZFBuffers call fzf#run(extend(s:fzf_default_opt, {
      \ 'source':  fzf#buffers_list(),
      \ 'sink':    'e',
      \ 'options': '--reverse --no-sort --prompt="buffers > "'
      \ }))

command! FZFMru call fzf#run(extend(s:fzf_default_opt, {
      \ 'source':  fzf#recent_files(),
      \ 'sink':    'e',
      \ 'options': '--reverse --multi --exit-0 --no-sort --prompt="mru > "'
      \ }))

command! FZFLines call fzf#run(extend(s:fzf_default_opt, {
      \ 'source':  fzf#buffers_lines(),
      \ 'sink':    function('fzf#buffers_lines_open'),
      \ 'options': '--reverse --no-sort --exit-0 --nth=3.. --prompt="lines > "'
      \ }))

nnoremap <silent> <c-p>      :FZFFiles<cr>
nnoremap <silent> <c-b>      :FZFBuffers<cr>

nnoremap <silent> <leader>fl :FZFLines<cr>
nnoremap <silent> <leader>fh :FZFMru<cr>

if has('nvim')
  augroup fzf_plugin
    au!

    au FileType fzf tnoremap <Esc> <c-\><c-n>:Sayonara!<cr>
  augroup END
endif
