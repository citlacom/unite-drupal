let s:save_cpo = &cpo
set cpo&vim

let s:unite_source = {
      \ 'name': 'drupal/dirs',
      \ 'description': 'Candidates from Drupal project.',
      \ 'is_volatile' : 1,
      \ }

function! s:open_dir(path)
  return printf("tabnew | lcd %s | Unite -auto-resize file_rec", a:path)
endfunction

function! s:unite_source.gather_candidates(args, context)
  let path = a:0 > 0 ? a:1 : getcwd()
  let paths = [path . ';', path . '*']
  let root = findfile('update.php', path . ';,' . path . '*')
  " Previous used buffer
  " bufname('#')
  if root == ""
    echomsg "Not located in a Drupal project"
    return []
  endif

  let root = fnamemodify(root, ":h:p")
  let places = [
        \ {'name' : 'core_includes', 'path' : root . '/includes'},
        \ {'name' : 'core_modules', 'path' : root . '/modules'},
        \ {'name' : 'core_misc', 'path' : root . '/misc'},
        \ {'name' : 'sites', 'path' : root . '/sites'},
        \ {'name' : 'sites_libraries', 'path' : root . '/sites/all/libraries'},
        \ {'name' : 'sites_contrib', 'path' : root . '/sites/all/modules/contrib'},
        \ {'name' : 'sites_features', 'path' : root . '/sites/all/modules/features'},
        \ {'name' : 'sites_custom', 'path' : root . '/sites/all/modules/custom'},
        \ {'name' : 'tests', 'path' : root . '/../tests'},
        \ ]

  return map(places, '{
        \ "abbr" : v:val.name,
        \ "word": v:val.path,
        \ "kind": "command",
        \ "action__command": s:open_dir(v:val.path),
        \}')
endfunction

function! unite#sources#drupaldirs#define()
  return s:unite_source
endfunction

let &cpo = s:save_cpo
unlet s:save_cpo
