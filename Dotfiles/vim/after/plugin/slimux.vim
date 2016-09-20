if has('mac')
  let g:slimux_tmux_path = '/usr/local/bin/tmux'
endif

let g:slimux_select_from_current_window = has('gui') ? 0 : 1
let g:slimux_restore_selection_after_visual = 1

map  <Plug>SlimuxSendBuffer :SlimuxREPLSendBuffer<cr>:call repeat#set("\<Plug>SlimuxSendBuffer")<cr>
map  <Plug>SlimuxSendNextParagraph }jvip:SlimuxREPLSendLine<cr>:call repeat#set("\<Plug>SlimuxSendNextParagraph")<cr>
map  <Plug>SlimuxSendPrevParagraph {jvip:SlimuxREPLSendLine<cr>:call repeat#set("\<Plug>SlimuxSendPrevParagraph")<cr>

map  <Plug>SlimuxSendParagraph :SlimuxREPLSendParagraph<cr>:call repeat#set("\<Plug>SlimuxSendParagraph")<cr>

map  <Plug>SlimuxSendParens :let slimux_view=winsaveview()<cr>
      \va):SlimuxREPLSendSelection<cr>
      \:call SlimuxSendKeys("Enter")<cr>
      \:call winrestview(slimux_view)<cr>
      \:call repeat#set("\<Plug>SlimuxSendParens")<cr>

map  <leader>sc :SlimuxGlobalConfigure<cr>
map  <leader>ss <Plug>SlimuxSendParagraph
map  <leader>sp <Plug>SlimuxSendParens
map  <leader>sb <Plug>SlimuxSendBuffer
map  <leader>s] <Plug>SlimuxSendNextParagraph
map  <leader>s[ <Plug>SlimuxSendPrevParagraph

xmap <leader>ss :SlimuxREPLSendSelection<cr>:call SlimuxSendKeys("Enter")<cr>

