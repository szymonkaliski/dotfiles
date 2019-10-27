" utils
command! KillWhitespace :call utils#kill_whitespace()
command! ShowSyntax :call utils#show_syntax()
command! Rename :call utils#rename_file()
command! Remove :call utils#remove_file()
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

" code TODO / FIXME in cwindow
command! Todo :call utils#find_todo()

" simple session.vim save/load
command! SaveSession :call session#save()
command! LoadSession :call session#load()

" plug
command! PlugUp :PlugUpdate | PlugUpgrade

" copy full file path (to system clipboard)
command! CPWD :let @+ = expand('%:p')

" redirect vim command output to scratch buffer
function! Redir(cmd)
  for win in range(1, winnr('$'))
    if getwinvar(win, 'scratch')
      execute win . 'windo close'
    endif
  endfor

  if a:cmd =~ '^!'
    execute "let output = system('" . substitute(a:cmd, '^!', '', '') . "')"
  else
    redir => output
    execute a:cmd
    redir END
  endif

  vnew

  let w:scratch = 1
  setlocal nobuflisted buftype=nofile bufhidden=wipe noswapfile
  call setline(1, split(output, '\n'))
endfunction

command! -nargs=1 -complete=command Redir silent call Redir(<f-args>)
