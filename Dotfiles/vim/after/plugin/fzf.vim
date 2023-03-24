augroup fzf_plugin
  au!

  au FileType fzf tnoremap <Esc> <c-c><c-\><c-n>:Sayonara!<cr>:echo<cr>
augroup END

let s:fzf_default_opt = { 'window': 'enew' }

" let s:fzf_preview_opt = ' --preview="highlight --config-file=$HOME/.highlight/hybrid-bw.theme -q -t 2 --force -O xterm256 {}"'
" let s:fzf_preview_opt = ' --preview="bat --style=plain --color=always --theme=base16-256 --line-range=:200 {}"'
let s:fzf_preview_opt = ''

let s:ignore_glob   = '*.{gif,png,jpg,jpeg,mp4,mkv,obj,ttf,sketch,zip}'
let s:ds_store_glob = '.DS_Store'
let s:rg_globs      = "-g '!" .. s:ignore_glob .. "' -g '!" .. s:ds_store_glob .. "'"
let s:fd_globs      = "-E '"  .. s:ignore_glob .. "' -E "   .. s:ds_store_glob

let s:fd_sort_modified_time = ' --exec stat -c "%Y:%n" | sort -nr | cut -d ":" -f2' " very slow
let s:fd_sort_none          = ''
let s:fd_sort               = s:fd_sort_none

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

" FIXME: this should probably be part of muninn scripts
function! fzf#wiki_open(l)
  let l:keys = split(a:l, ':')

  let l:file = l:keys[0]
  let l:line = l:keys[1]

  exe 'e ' . muninn#wiki_path() . l:file
  exe ':' . l:line
  norm zz
endfunction

function! fzf#file_line_open(l)
  let l:keys = split(a:l, ':')

  let l:file = l:keys[0]
  let l:line = l:keys[1]

  exe 'e ' . l:file
  exe ':' . l:line
  norm zz
endfunction

command! FZFFilesFolders call fzf#run(extend(s:fzf_default_opt, {
      \ 'source':  'fd --hidden --follow --exclude .git ' . s:fd_globs . s:fd_sort,
      \ 'sink':    'e',
      \ 'dir':     getcwd(),
      \ 'options': '--multi --exit-0 --prompt="files > "' . s:fzf_preview_opt
      \ }))

command! FZFWiki call fzf#run(extend(s:fzf_default_opt, {
      \ 'source':  'rg --no-heading --line-number --with-filename "." ' . s:rg_globs,
      \ 'sink':    function('fzf#wiki_open'),
      \ 'dir':     muninn#wiki_path(),
      \ 'options': '--exit-0 --prompt="wiki > "' . s:fzf_preview_opt
      \ }))

command! FZFLines call fzf#run(extend(s:fzf_default_opt, {
      \ 'source':  'rg --no-heading --line-number --with-filename "." ' . s:rg_globs,
      \ 'sink':    function('fzf#file_line_open'),
      \ 'dir':     getcwd(),
      \ 'options': '--exit-0 --prompt="lines > "'
      \ }))

command! FZFBuffers call fzf#run(extend(s:fzf_default_opt, {
      \ 'source':  fzf#buffers_list(),
      \ 'sink':    'e',
      \ 'options': '--exit-0 --prompt="buffers > "' . s:fzf_preview_opt
      \ }))

command! FZFMru call fzf#run(extend(s:fzf_default_opt, {
      \ 'source':  fzf#recent_files(),
      \ 'sink':    'e',
      \ 'options': '--multi --exit-0 --prompt="mru > "' . s:fzf_preview_opt
      \ }))

nnoremap <silent> <c-p>      :FZFFilesFolders<cr>
nnoremap <silent> <c-b>      :FZFBuffers<cr>

nnoremap <silent> <leader>fl :FZFLines<cr>
nnoremap <silent> <leader>fh :FZFMru<cr>
nnoremap <silent> <leader>fw :FZFWiki<cr>

