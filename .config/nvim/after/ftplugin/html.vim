"{{{ indentation

setl softtabstop=2 shiftwidth=2

let g:html_indent_script1 = "inc"
let g:html_indent_style1 = "inc"

"}}}
"{{{ formatprg

if executable("prettier")
  set formatprg=prettier\ --parser\ html
endif

"}}}
"{{{ firefox

nnoremap <silent><buffer> <F5> :silent !firefox --new-window "%" &<CR>

"}}}
"{{{ completion

setl omnifunc=emmet#completeTag

let b:completion_command = "\<C-x>\<C-o>"
let b:completion_length = 1

"}}}
"{{{ abbreviations

iabbr <buffer><silent> clog console.log();<Left><Left><C-R>=Eatchar('\s')<CR>
iabbr consoel console
iabbr lenght length
iabbr edf export default function
iabbr ireact import React from "react";

"}}}
