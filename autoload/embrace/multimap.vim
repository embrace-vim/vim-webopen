" vim:tw=0:ts=2:sw=2:et:norl
" Author: Landon Bouma <https://tallybark.com/>
" Project: https://github.com/embrace-vim/vim-web-hatch#🐣
" License: GPLv3

" -------------------------------------------------------------------

" USAGE: After editing this plugin, you can reload it on the fly with
"        https://github.com/landonb/vim-source-reloader#↩️
" - Uncomment this `unlet` (or disable the `finish`) and hit <F9>.
"
" silent! unlet g:loaded_vim_web_hatch_autoload_multimap

if exists("g:loaded_vim_web_hatch_autoload_multimap") || &cp

  finish
endif

let g:loaded_vim_web_hatch_autoload_multimap = 1

" -------------------------------------------------------------------

" ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
" Key sequence command map utilities
" ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

function! s:create_maps(maps_key, solo_var, default_seq, n_cmd, i_cmd, v_cmd) abort
  try
    call s:create_mode_maps(a:maps_key, a:solo_var, a:default_seq, a:n_cmd, a:i_cmd, a:v_cmd)
  catch
    echom "ALERT: vim-web-hatch: Failed to wire mode maps for '" .. a:maps_key .. "' command"
    echom "v:exception: " .. v:exception
  endtry
endfunction

" ***

function! s:create_mode_maps(maps_key, solo_var, default_seq, n_cmd, i_cmd, v_cmd) abort
  let l:maps_var = "g:vim_web_hatch_maps['" .. a:maps_key .."']"

  if exists("g:vim_web_hatch_maps") && exists(l:maps_var)
    let l:feature_val = g:vim_web_hatch_maps[a:maps_key]
    let l:val_type = type(l:feature_val)

    if l:val_type == v:t_string || l:val_type == v:t_list
      let l:all_keys = s:listify(l:feature_val, l:maps_var)

      let l:n_keys = all_keys
      let l:i_keys = all_keys
      let l:v_keys = all_keys
    elseif l:val_type == v:t_dict
      let l:n_keys = s:listify(get(l:feature_val, "nmap", []), l:maps_var)
      let l:i_keys = s:listify(get(l:feature_val, "imap", []), l:maps_var)
      let l:v_keys = s:listify(get(l:feature_val, "vmap", []), l:maps_var)
    else
      echom "ALERT: vim-web-hatch: Unrecognized value type for g:vim_web_hatch_maps['"
        \ .. a:maps_key .."']: " .. l:val_type

      return
    endif
  else
    let l:all_keys = s:listify(get(g:, a:solo_var, a:default_seq), "g:" .. a:solo_var)

    let l:n_keys = all_keys
    let l:i_keys = all_keys
    let l:v_keys = all_keys
  endif

  call s:remap_maps("n", l:n_keys, a:n_cmd)
  call s:remap_maps("i", l:i_keys, a:i_cmd)
  call s:remap_maps("v", l:v_keys, a:v_cmd)
endfunction

" ***

function! s:remap_maps(map_mode, map_keys, map_cmd) abort
  for l:seq in a:map_keys
    if maparg(l:seq, a:map_mode) == ""
      exe a:map_mode .. "noremap <silent> " .. l:seq .. " " .. a:map_cmd
    else
      echom "ALERT: vim-web-hatch skipped already-claimed " .. a:map_mode .. "map sequence: " .. l:seq
    endif
  endfor
endfunction

" ***

function! s:listify(string_or_list, var_name) abort
  let l:val_type = type(a:string_or_list)

  if l:val_type == v:t_string

    return [a:string_or_list]
  elseif l:val_type == v:t_list

    return a:string_or_list
  else
    echom "ALERT: vim-web-hatch: Unrecognized value type for '"
      \ .. a:var_name .."': " .. l:val_type

    throw "listify: not a string or list"
  endif
endfunction

