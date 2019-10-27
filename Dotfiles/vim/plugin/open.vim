if !has('mac')
  finish
end

map <Plug>OpenURLNormal :call utils#open_url(0)<cr>:call repeat#set('\<Plug>OpenURLNormal')<cr>
map <Plug>OpenURLVisual :call utils#open_url(1)<cr>:call repeat#set('\<Plug>OpenURLVisual')<cr>

nmap gx <Plug>OpenURLNormal
xmap gx <Plug>OpenURLVisual

" map <Plug>OpenQuicklookNormal :call utils#open_quicklook(0)<cr>:call repeat#set('\<Plug>OpenQuicklookNormal')<cr>
" map <Plug>OpenQuicklookVisual :call utils#open_quicklook(1)<cr>:call repeat#set('\<Plug>OpenQuicklookVisual')<cr>

nmap go :call utils#open_quicklook(0)<cr>
xmap go :call utils#open_quicklook(1)<cr>

