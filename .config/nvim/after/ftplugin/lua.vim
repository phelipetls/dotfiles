" default identation
set expandtab
set softtabstop=2
set shiftwidth=2

setlocal makeprg=luacheck\ --no-color\ %
let &l:errorformat=&g:errorformat.",%-G%.%#"
