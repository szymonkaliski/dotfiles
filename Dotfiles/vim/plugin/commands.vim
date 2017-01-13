" utils
command! KillWhitespace :call utils#kill_whitespace()
command! ShowSyntax :call utils#show_syntax()
command! Rename :call utils#rename_file()
command! ZoomToggle call utils#zoom_split()

" open multiple files
command! -complete=file -nargs=+ E call utils#E(<f-args>)

" clean non-visible buffers
command! -bang Wipeout :call utils#wipeout(<bang>0)

" tab to space and back
command! TabToSpace :setlocal expandtab | %retab!
command! SpaceToTab :setlocal noexpandtab | %retab!

" spelling
command! SpellPL :setlocal spelllang=pl | setlocal spell
command! SpellEN :setlocal spelllang=en | setlocal spell

" grepping
command! -nargs=? Grep       :call grep#grep(<f-args>)
command! -range   GrepVisual :call grep#grep_visual()

" code TODO / FIXME in cwindow
command! Todo :call utils#find_todo()

" simple session.vim save/load
command! SaveSession :call session#save()
command! LoadSession :call session#load()

" counting days/hours in logs
command! -range=% -nargs=0 CountWorkedDays :<line1>,<line2>call workcount#days()
command! -range=% -nargs=0 CountWorkedHours :<line1>,<line2>call workcount#hours()

" notes handling
command! -nargs=1 -complete=custom,notes#complete_notes Note call notes#note(<f-args>)

" Today view - taskpaper + drafts in split,
" folds open on @today and last section of drafts
function! s:show_today()
  e ~/Documents/Dropbox/Tasks/Todo.taskpaper
  norm zM
  %g/\v^(.*\@today)&(.*\@done)@!/foldopen!
  norm gg
  vsp ~/Documents/Dropbox/Notes/drafts.txt
  " silent! norm zMGzazz
  redraw!
endfunction

command! Today call <sid>show_today()
