augroup auto_quickfix
  au!

  " automatically open quickfix / loclist
  au QuickFixCmdPost grep,make,grepadd,vimgrep,vimgrepadd,cscope,cfile,cgetfile,caddfile,helpgrep cwindow
  au QuickFixCmdPost lgrep,lmake,lgrepadd,lvimgrep,lvimgrepadd,lfile,lgetfile,laddfile            lwindow

  " automatically positions quickfix / loclist on the bottom
  au FileType qf wincmd J
augroup END
