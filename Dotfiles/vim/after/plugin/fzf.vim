if has('gui')
  finish
endif

function! s:BuffersList()
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

function! s:RecentFiles()
  return filter(v:oldfiles, 'filereadable(glob(v:val))')
endfunction

function! s:AgSearchInput()
  let l:input = input('Grep for: ')

  if len(l:input) > 0
    return s:AgSearchHandler(l:input)
  else
    return ''
  endif
endfunction

function! s:AgSearchVisual()
  let [l:lnum1, l:col1] = getpos("'<")[1:2]
  let [l:lnum2, l:col2] = getpos("'>")[1:2]
  let l:lines = getline(l:lnum1, l:lnum2)
  let l:lines[-1] = l:lines[-1][: l:col2 - (&selection == 'inclusive' ? 1 : 2)]
  let l:lines[0] = l:lines[0][l:col1 - 1:]

  let l:selection = join(l:lines, '\n')

  return s:AgSearchHandler(l:selection)
endfunction

function! s:AgSearchHandler(search)
  return 'ag --smart-case --nogroup --color --column "' . a:search . '"'
endfunction

function! s:AgHandler(e)
  let l:keys = split(a:e, ':')
  let l:line = l:keys[1]
  let l:col  = l:keys[2]
  let l:file = escape(l:keys[0], ' ')

  exe 'e ' . l:file
  call cursor(l:line, l:col)
  silent! normal! zozz
endfunction

function! s:BuffersLines()
  let res = []

  for b in filter(range(1, bufnr('$')), 'buflisted(v:val)')
    call extend(res, map(getbufline(b,0,'$'), "b . ':' . (v:key + 1) . ':\t' . v:val "))
  endfor

  return res
endfunction

function! s:BuffersLinesOpen(l)
  let keys = split(a:l, ':')
  exe 'buffer ' . keys[0]
  exe keys[1]
  silent! normal! zozz
endfunction

function! s:Registers()
  let l:regnum =  range(char2nr('a'), char2nr('z'))
  let l:regnum += range(char2nr('0'), char2nr('9'))
  let l:regstr =  [ '"' ]
  let l:regnum += map(l:regstr, 'char2nr(v:val)')

  let l:regnum = filter(l:regnum, "getreg(nr2char(v:val)) != ''")
  let l:regnum = filter(l:regnum, "getreg(nr2char(v:val)) !~ '^$'")
  let l:regnum = filter(l:regnum, "getreg(nr2char(v:val)) !~ '^\s\+$'")
  let l:regnum = filter(l:regnum, "getreg(nr2char(v:val)) !~ '^\W\+$'")

  let l:registers = map(l:regnum, 'getreg(nr2char(v:val))')

  return l:registers
endfunction

function! s:LineAppend(e)
  exe 'normal! o ' . a:e
endfunction

let s:fzf_default_opt = { 'window': 'enew' }
" let s:fzf_default_opt = { 'down': '20%' }

command! FZFFiles call fzf#run(extend(s:fzf_default_opt, {
      \ 'source':  'ag -l -g ""',
      \ 'sink':    'e',
      \ 'options': '--reverse --multi --exit-0 --prompt="files > "'
      \ }))

command! FZFBuffers call fzf#run(extend(s:fzf_default_opt, {
      \ 'source':  s:BuffersList(),
      \ 'sink':    'e',
      \ 'options': '--reverse --no-sort --prompt="buffers > "'
      \ }))

command! FZFMru call fzf#run(extend(s:fzf_default_opt, {
      \ 'source':  s:RecentFiles(),
      \ 'sink':    'e',
      \ 'options': '--reverse --multi --exit-0 --no-sort --prompt="mru > "'
      \ }))

command! FZFAgInput call fzf#run(extend(s:fzf_default_opt, {
      \ 'source':  s:AgSearchInput(),
      \ 'sink':    function('<sid>AgHandler'),
      \ 'options': '--reverse --ansi --multi --exit-0 --prompt="grep > "'
      \ }))

command! -range FZFAgVisual call fzf#run(extend(s:fzf_default_opt, {
      \ 'source':  s:AgSearchVisual(),
      \ 'sink':    function('<sid>AgHandler'),
      \ 'options': '--reverse --ansi --multi --exit-0 --prompt="grep > "'
      \ }))

command! FZFLines call fzf#run(extend(s:fzf_default_opt, {
      \ 'source':  s:BuffersLines(),
      \ 'sink':    function('<sid>BuffersLinesOpen'),
      \ 'options': '--reverse --no-sort --exit-0 --nth=3.. --prompt="lines > "'
      \ }))

command! FZFRegisters call fzf#run(extend(s:fzf_default_opt, {
      \ 'source':  s:Registers(),
      \ 'sink':    function('<sid>LineAppend'),
      \ 'options': '--reverse --no-sort --tac --exit-0 --prompt="registers > "'
      \ }))

nnoremap <silent> <c-p>      :FZFFiles<cr>
nnoremap <silent> <c-b>      :FZFBuffers<cr>

nnoremap <silent> <leader>fe :FZFFiles<cr>
nnoremap <silent> <leader>fb :FZFBuffers<cr>
nnoremap <silent> <leader>fl :FZFLines<cr>
nnoremap <silent> <leader>fm :FZFMru<cr>
nnoremap <silent> <leader>fh :FZFRegisters<cr>
nnoremap <silent> <leader>fr :FZFRegisters<cr>

nnoremap <silent> <leader>fg :FZFAgInput<cr>
xnoremap <silent> <leader>fg :FZFAgVisual<cr>

if isdirectory($HOME . '/Documents/Dropbox/Notes')
  command! FZFNotes call fzf#run(extend(s:fzf_default_opt, {
        \ 'source':  'find ~/Documents/Dropbox/Notes -iname "*.txt" | cut -d "/" -f7 | sed "s/\.txt$//"',
        \ 'sink':    function('s:OpenNote'),
        \ 'options': '--reverse --multi --prompt="notes > "'
        \ }))

  function! s:OpenNote(e)
    exe 'e ~/Documents/Dropbox/Notes/' . escape(a:e, ' ') . '.txt'
  endfunction

  nnoremap <silent> <leader>fn :FZFNotes<cr>
endif

if isdirectory($HOME . '/Documents/Dropbox/Tasks')
  command! FZFTasks call fzf#run(extend(s:fzf_default_opt, {
        \ 'source':  'find ~/Documents/Dropbox/Tasks -iname "*.taskpaper" | cut -d "/" -f7 | sed "s/\.taskpaper$//"',
        \ 'sink':    function('<sid>OpenTask'),
        \ 'options': '--reverse --multi --prompt="tasks > "'
        \ }))

  function! s:OpenTask(e)
    exe 'e ~/Documents/Dropbox/Tasks/' . escape(a:e, ' ') . '.taskpaper'
  endfunction

  nnoremap <silent> <leader>ft :FZFTasks<cr>
endif

if has('nvim')
  augroup fzf_plugin
    au!

    " au FileType fzf tnoremap <Esc> <c-c>
    au FileType fzf tnoremap <Esc> <c-\><c-n>:Sayonara!<cr>
  augroup END
endif
