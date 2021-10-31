if executable("shellcheck")
  setlocal makeprg=shellcheck\ --format\ gcc
  setlocal errorformat=%f:%l:%c:\ %m
endif

nnoremap <F5> :!./%<CR>
