let s:save_cpo = &cpo
set cpo&vim

let s:unite_source = {
      \ 'name': 'drupal/watchdog',
      \ 'description': 'candidates for your drupal watchdog'
      \ }

function! unite#sources#watchdog#projname()
  let path = split(unite#util#path2project_directory(expand('%')), '/')
  let idx = len(path)-1
  return(path[idx])
endfunction

function! unite#sources#watchdog#open(wid)
  let command = 'drush @' . unite#sources#watchdog#projname() . ' watchdog-unitedt --wid=' . a:wid
  let output = system(command)
  if &buftype != 'nofile' || &filetype == 'help'
    new
    set nomodified
    file debug
    set filetype=debug
    setlocal buftype=nofile
    NeoCompleteLock
  else
    normal! ggdG
  endif
  normal I<?php
  put =output
  normal! gg
endfunction

function! s:unite_source.gather_candidates(args, context)
  let command = 'drush @' . unite#sources#watchdog#projname() . ' watchdog-unitels --count=40 --type=debug'
  let resjson = system(command)
  let candidates = []
  let json = []

  if resjson =~ 'Drupal installation directory could not be found'
    echomsg 'Drupal installation directory could not be found'
    return(candidates)
  endif

  try
    lua << EOF
    do
      local resjson = vim.eval('resjson')
      local filepath = os.getenv("HOME") .. '/.vim/JSON.lua'
      JSON = (loadfile(filepath))()
      local json = JSON:decode(resjson)
      local ret = vim.eval('candidates')
      for i = 1, #json do
        local row = json[i]
        local title = row[1] .. ' - ' .. row[2] .. ' - ' .. row[3]
        local list = vim.list()
        list:add(title)
        list:add(row[4])
        ret:add(list)
      end
   end
EOF

    return map(copy(candidates), '{
          \ "word": v:val[0],
          \ "source": "watchdog",
          \ "kind": "command",
          \ "action__command": "call unite#sources#watchdog#open(''".v:val[1]."'')"
          \ }')
  catch
    return(candidates)
  endtry
endfunction

function! unite#sources#watchdog#define()
  return s:unite_source
endfunction

let &cpo = s:save_cpo
unlet s:save_cpo

