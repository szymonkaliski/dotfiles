let g:Illuminate_delay = 50
let g:Illuminate_ftblacklist = ['dirvish', 'undotree', 'help', 'text', 'markdown', 'taskpaper']

let g:illuminate_enabled = 1

function! s:illuminate_toggle()
  IlluminationToggle
  let g:illuminate_enabled = !g:illuminate_enabled
  echom g:illuminate_enabled ? 'Illuminate: Enabled' : 'Illuminate: Disabled'
endfunction

command! IlluminateToggle :call <sid>illuminate_toggle()

nnoremap coi :<c-u>IlluminateToggle<cr>

