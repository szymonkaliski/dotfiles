if !has('mac')
  finish
end

map <Plug>OpenURLNormal :call utils#open_url(0)<cr>:call repeat#set("\<Plug>OpenURLNormal")<cr>
map <Plug>OpenURLVisual :call utils#open_url(1)<cr>:call repeat#set("\<Plug>OpenURLVisual")<cr>

nmap gx <Plug>OpenURLNormal
xmap gx <Plug>OpenURLVisual
