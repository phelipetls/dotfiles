if exists("current_compiler")
  finish
endif
let current_compiler = "pytest"

if exists(":CompilerSet") != 2		" older Vim always used :setlocal
  command -nargs=* CompilerSet setlocal <args>
endif

CompilerSet makeprg=pytest\ -s\ -vv\ --tb=native\ %
CompilerSet errorformat=\%C\ %.%#,
      \%CE\ %\\{3}%p^,
      \%CE\ %\\{5}%.%#,
      \%EE\ %\\{5}File\ \"%f\"\\,\ line\ %l,
      \%ZE\ %\\{3}%m,
      \%A\ \ File\ \"%f\"\\,\ line\ %l\\,\ in\ %o,
      \%Z%[%^\ ]%\\@=%m,
      \%+G\ +%.%#,
      \%-G%.%#,
