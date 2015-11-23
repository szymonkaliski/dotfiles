" re-source vimrc
if !exists('*ReloadSettings')
  function! ReloadSettings()
    source $MYVIMRC
    if has('gui') | source $MYGVIMRC | endif

    setlocal foldmethod=marker

    AirlineRefresh

    echo 'Settings reloaded'
  endfunction

  command! ReloadSettings :call ReloadSettings()
endif

" loads multiple files
function! E(...)
  for f1 in a:000
    let files = glob(f1)
    if files == ''
      execute 'e ' . escape(f1, '\ "')
    else
      for f2 in split(files, "\n")
        execute 'e ' . escape(f2, '\ "')
      endfor
    endif
  endfor
endfunction

command! -complete=file -nargs=+ E call E(<f-args>)

" kills trailing whitespaces
function! s:KillWhitespace()
  let l:cursor_pos = getpos('.')
  keepjumps keeppatterns %s/\s\+$//e
  call setpos('.', l:cursor_pos)

  echo 'Whitespace cleaned'
endfunction

command! KillWhitespace :call <sid>KillWhitespace()

" shows syntax highlight group for element
function! s:ShowSyntax()
  echo join(map(synstack(line('.'), col('.')), 'synIDattr(v:val, "name")'), ' > ')
endfunction

command! ShowSyntax :call <sid>ShowSyntax()

" destroy all buffers that are not open in any tabs or windows
" https://github.com/artnez/vim-wipeout/blob/master/plugin/wipeout.vim
function! s:Wipeout(bang)
  " figure out which buffers are visible in tabs
  let l:visible = {}

  for t in range(1, tabpagenr('$'))
    for b in tabpagebuflist(t)
      let l:visible[b] = 1
    endfor
  endfor

  " close buffers that are loaded and not visible
  let l:tally = 0
  let l:cmd = 'bw'

  if a:bang
    let l:cmd = l:cmd . '!'
  endif

  for b in range(1, bufnr('$'))
    if buflisted(b) && !has_key(l:visible, b)
      let l:tally += 1
      exe l:cmd . ' ' . b
    endif
  endfor

  echon 'Deleted ' . l:tally . ' buffer' . (l:tally == 1 ? '' : 's')
endfunction

command! -bang Wipeout :call <sid>Wipeout(<bang>0)

" rename current file
function! s:Rename()
  let l:old_name = expand('%')
  let l:new_name = input('New file name: ', fnameescape(expand('%')), 'file')

  if l:new_name != '' && l:new_name != l:old_name
    exe ':saveas ' . l:new_name
    exe ':silent !rm ' . l:old_name
    exe ':e!'
  endif
endfunction

command! Rename :call <sid>Rename()

" tab to space and back
command! TabToSpace :setlocal expandtab | %retab!
command! SpaceToTab :setlocal noexpandtab | %retab!

" spelling
command! SpellPL :setlocal spelllang=pl | setlocal spell
command! SpellEN :setlocal spelllang=en | setlocal spell

" location jumps
function! FixPrevious(prev, last)
  try
    exe a:prev
  catch
    try | exe a:last | catch | endtry
  endtry
endfunction

function! FixNext(next, first)
  try
    exe a:next
  catch
    try | exe a:first | catch | endtry
  endtry
endfunction

" makes * and # work in visual mode
function! VisualSearch(cmdtype)
  let l:temp = @s
  normal! gv"sy
  let @/ = '\V' . substitute(escape(@s, a:cmdtype.'\'), '\n', '\\n', 'g')
  let @s = l:temp
endfunction

" grep
function! s:GrepHandler(text)
  exe 'silent grep! ' . a:text
  exe 'silent /' . a:text
  redraw!
endfunction

function! s:Grep()
  let l:input = input('Grep for: ')

  call <sid>GrepHandler(l:input)
endfunction

function! s:GrepVisual()
  let [l:lnum1, l:col1] = getpos("'<")[1:2]
  let [l:lnum2, l:col2] = getpos("'>")[1:2]
  let l:lines = getline(l:lnum1, l:lnum2)
  let l:lines[-1] = l:lines[-1][: l:col2 - (&selection == 'inclusive' ? 1 : 2)]
  let l:lines[0] = l:lines[0][l:col1 - 1:]

  let l:selection = join(l:lines, '\n')

  call <sid>GrepHandler(l:input)
endfunction

command!        Grep       :call <sid>Grep()
command! -range GrepVisual :call <sid>GrepVisual()

" code TODO / FIXME in cwindow
function! s:Todo() abort
  let entries = []

  for cmd in [ 'git grep -n -e TODO -e FIXME 2> /dev/null', 'ag --vimgrep "(TODO|FIXME)" 2> /dev/null' ]
    let lines = split(system(cmd), '\n')
    if v:shell_error != 0 | continue | endif
    for line in lines
      let [fname, lno, text] = matchlist(line, '^\([^:]*\):\([^:]*\):\(.*\)')[1:3]
      call add(entries, { 'filename': fname, 'lnum': lno, 'text': text })
    endfor
    break
  endfor

  if !empty(entries)
    call setqflist(entries)
    copen
  endif
endfunction

command! Todo :call <sid>Todo()

" save and load session from session.vim
function! s:SaveSession()
  let l:dir = fnameescape(getcwd())
  exe 'mksession! ' . l:dir . '/session.vim'
endfunction

function! s:LoadSession()
  let l:dir = fnameescape(getcwd())
  exe 'silent! source ' . l:dir . '/session.vim'
endfunction

command! SaveSession :call <sid>SaveSession()
command! LoadSession :call <sid>LoadSession()

function! s:PipeThroughScript(lines, script)
  let l:cli = ''

  let l:cli = l:cli . 'echo ' . shellescape(join(a:lines, '\n'))
  let l:cli = l:cli . ' | ' . a:script

  return system(l:cli)
endfunction

" count worked days looking like this:
" day1: 1/2
" day2: 3/4
" day3: 1
" basically pipe throught simple node script

function! s:CountWorkedDays() range
  echomsg 'Worked days: ' . <sid>PipeThroughScript(getline(a:firstline, a:lastline), 'count-work-days')
endfunction

command! -range=% -nargs=0 CountWorkedDays :<line1>,<line2>call <sid>CountWorkedDays()

" count worked hours looking like this:
" project1
" 10:00 - 12:00
" project2
" 13:00 - 13:30
" basically pipe through simple node script

function! s:CountWorkedHours() range
  echomsg <sid>PipeThroughScript(getline(a:firstline, a:lastline), 'count-work-hours')
endfunction

command! -range=% -nargs=0 CountWorkedHours :<line1>,<line2>call <sid>CountWorkedHours()

" zoom / restore window
function! s:ZoomToggle() abort
  if exists('t:zoomed') && t:zoomed
    exec t:zoom_winrestcmd
    let t:zoomed = 0
  else
    let t:zoom_winrestcmd = winrestcmd()
    resize
    vertical resize
    let t:zoomed = 1
  endif
endfunction

command! ZoomToggle call <sid>ZoomToggle()
