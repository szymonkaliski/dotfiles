let g:windowswap_map_keys = 0

nnoremap <silent> <c-w>y :call WindowSwap#MarkWindowSwap()<cr>
nnoremap <silent> <c-w>p :call WindowSwap#DoWindowSwap()<cr>
