au BufNewFile,BufRead *.ts  let b:tsx_ext_found = 0 | setlocal filetype=typescript
au BufNewFile,BufRead *.tsx let b:tsx_ext_found = 1 | setlocal filetype=typescript.tsx
