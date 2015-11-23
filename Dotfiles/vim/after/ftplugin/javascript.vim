setlocal foldmethod=syntax
setlocal suffixesadd=.js,.jsx
setlocal makeprg=javascript\ %
setlocal errorformat=%Evm.js:%*\\d:\ Uncaught\ SyntaxError:\ %f:%l,\ %C%m,%Z%m,%AError:\ %m,%AEvalError:\ %m,%ARangeError:\ %m,%AReferenceError:\ %m,%ASyntaxError:\ %m,%ATypeError:\ %m,%Z%*[\ ]at\ %f:%l:%c,%Z%*[\ ]%m\ \(%f:%l:%c\),%*[\ ]%m\ \(%f:%l:%c\),%*[\ ]at\ %f:%l:%c,%Z%p^,%A%f:%l,%C%m,%-G%.%#
