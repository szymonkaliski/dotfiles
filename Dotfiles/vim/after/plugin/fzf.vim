augroup fzf_plugin
  au!

  au FileType fzf tnoremap <Esc> <c-c><c-\><c-n>:Sayonara!<cr>:echo<cr>
augroup END

let s:fzf_default_opt = { 'window': 'enew' }
" let s:fzf_preview_opt = ' --preview="highlight --config-file=$HOME/.highlight/hybrid-bw.theme -q -t 2 --force -O xterm256 {}"'
let s:fzf_preview_opt = ''

let s:rg_globs = "-g '!*.{png,jpg,jpeg,mp4,mkv,obj,ttf,sketch,zip}' -g '!.DS_Store'"
let s:wiki_dir = '~/Documents/Dropbox/Wiki/'

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
  " checking if each file is readable slows this down
  " return filter(v:oldfiles, 'filereadable(glob(v:val))')

  return v:oldfiles
endfunction

function! fzf#buffers_lines()
  let res = []

  for b in filter(range(1, bufnr('$')), 'buflisted(v:val)')
    call extend(res, map(getbufline(b,0,'$'), "b . ':' . (v:key + 1) . ':\t' . v:val "))
  endfor

  return res
endfunction

function! fzf#buffers_lines_open(l)
  let l:keys = split(a:l, ':')
  exe 'buffer ' . l:keys[0]
  exe l:keys[1]
  silent! normal! zozz
endfunction

" FIXME: this should probably be part of muninn scripts
function! fzf#wiki_open(l)
  let l:keys = split(a:l, ':')

  let l:file = l:keys[0]
  let l:line = l:keys[1]

  exe 'e ' . s:wiki_dir . l:file
  exe ':' . l:line
endfunction

function! s:fzf_dir_files()
  call fzf#run(extend(s:fzf_default_opt, {
        \ 'source':  'rg --files --hidden --follow --no-messages ' . s:rg_globs,
        \ 'sink':    'e',
        \ 'dir':     dirvish#get_current_path(),
        \ 'options': '--reverse --multi --exit-0 --prompt="files > "' . s:fzf_preview_opt
        \ }))
endfunction

function! s:fzf_files()
  call fzf#run(extend(s:fzf_default_opt, {
        \ 'source':  'rg --files --hidden --follow --no-messages ' . s:rg_globs,
        \ 'sink':    'e',
        \ 'dir':     getcwd(),
        \ 'options': '--reverse --multi --exit-0 --prompt="files > "' . s:fzf_preview_opt
        \ }))
endfunction

function! s:fzf_wiki()
  call fzf#run(extend(s:fzf_default_opt, {
        \ 'source':  'rg --no-heading --line-number --with-filename "." ' . s:rg_globs,
        \ 'sink':    function('fzf#wiki_open'),
        \ 'dir':     s:wiki_dir,
        \ 'options': '--reverse --exit-0 --prompt="wiki > "' . s:fzf_preview_opt
        \ }))
endfunction

command! FZFFiles    call <sid>fzf_files()
command! FZFDirFiles call <sid>fzf_dir_files()
command! FZFWiki     call <sid>fzf_wiki()

command! FZFBuffers call fzf#run(extend(s:fzf_default_opt, {
      \ 'source':  fzf#buffers_list(),
      \ 'sink':    'e',
      \ 'options': '--reverse --no-sort --prompt="buffers > "' . s:fzf_preview_opt
      \ }))

command! FZFMru call fzf#run(extend(s:fzf_default_opt, {
      \ 'source':  fzf#recent_files(),
      \ 'sink':    'e',
      \ 'options': '--reverse --multi --exit-0 --no-sort --prompt="mru > "' . s:fzf_preview_opt
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
nnoremap <silent> <leader>fw :FZFWiki<cr>
