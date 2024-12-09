" vim:tw=0:ts=2:sw=2:et:norl
" Author: Landon Bouma <https://tallybark.com/>
" Project: https://github.com/embrace-vim/vim-web-hatch#🐣
" License: GPLv3

" -------------------------------------------------------------------

" USAGE: After editing this plugin, you can reload it on the fly with
"        https://github.com/landonb/vim-source-reloader#↩️
" - Uncomment this `unlet` (or disable the `finish`) and hit <F9>.
"
" silent! unlet g:loaded_vim_web_hatch_plugin

if exists("g:loaded_vim_web_hatch_plugin") || &cp

  finish
endif

let g:loaded_vim_web_hatch_plugin = 1

" -------------------------------------------------------------------

" ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
" Search Web for Selection, or Word Under Cursor
" ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

" USAGE:
"
" Search for the term under the cursor or selected, e.g.,
" https://www.google.com/search?q=<TERM>
"
" - To define the map sequences, use g:vim_web_hatch_maps["search"],
"   e.g.,
"
"     let g:vim_web_hatch_maps = {
"       \   'search':
"       \   {
"       \     'nmap': '<Leader>W',
"       \     'imap': '<Leader>W',
"       \     'vmap': '<Leader>W',
"       \   },
"       ...
"
" - Or simplify the config if you want the same sequence used for all
"   three modes, e.g.,
"
"     let g:vim_web_hatch_maps = {
"       \   'search': '<Leader>W',
"       ...
"
" - Alternatively, if g:vim_web_hatch_maps["search"] is not defined,
"   you can use g:vim_web_hatch_google_search_seq instead, e.g.,
"
"     let g:vim_web_hatch_google_search_seq = '<Leader>W'
"
"   and that sequence will be used to create maps for each of the
"   three modes, normal, insert, and visual.
"
" - To disable a map, set the 'nmap', 'imap', or 'vmap' entry to
"   an empty string or an empty list; or set fallback variable
"   (g:vim_web_hatch_google_search_seq) to an empty string.
"
" - Default value: If neither g:vim_web_hatch_maps["search"]
"   nor g:vim_web_hatch_google_search_seq is defined, and if
"   the sequence is not already mapped, defaults to:
"
"     <Leader>W

function! s:place_binding_search_web_for_selection()
  " Note that Chrome opens the URL as-is, i.e., it's not like the location
  " bar where Chrome will search Google instead if the location is missing
  " a 'scheme://'. So specify the complete URL.
  let l:n_cmd = ":call embrace#browser#web_open_url('https://www.google.com/search?q=<C-R><C-W>', 0)<CR>"
  let l:i_cmd = "<C-O>" .. n_cmd
  " SAVVY: C-U clears the command line, which contains cruft, e.g., '<,'>
  " - gv selects the previous Visual area.
  " - y yanks the selected text into the default register.
  " - <Ctrl-R>" puts the yanked text into the command line.
  let l:v_cmd =
    \ " :<C-U>" ..
    \ "<CR>gvy" ..
    \ ":<C-U>call embrace#browser#web_open_url('https://www.google.com/search?q=<C-R>\"', 0)<CR>"

  " Traditional default: \W opens browser to Google search of selected text.
  call embrace#multimap#create_maps(
    \ "search",
    \ "vim_web_hatch_google_search_seq",
    \ "<Leader>W",
    \ l:n_cmd,
    \ l:i_cmd,
    \ l:v_cmd)
endfunction

" -------------------------------------------------------------------

" ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
" Search Web for Definition of Selection, or Word Under Cursor
" ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

" USAGE:
"
" Search for the term under the cursor or selected, e.g.,
" https://www.google.com/search?q=define+<TERM>
"
" - To define the map sequences, use g:vim_web_hatch_maps["define"],
"   e.g.,
"
"     let g:vim_web_hatch_maps = {
"       \   'define':
"       \   {
"       \     'nmap': '<Leader>D',
"       \     'imap': '<Leader>D',
"       \     'vmap': '<Leader>D',
"       \   },
"       ...
"
" - Or simplify the config if you want the same sequence used for all
"   three modes, e.g.,
"
"     let g:vim_web_hatch_maps = {
"       \   'define': '<Leader>D',
"       ...
"
" - Alternatively, if g:vim_web_hatch_maps["define"] is not defined,
"   you can use g:vim_web_hatch_google_define_seq instead, e.g.,
"
"     let g:vim_web_hatch_google_define_seq = '<Leader>D'
"
"   and that sequence will be used to create maps for each of the
"   three modes, normal, insert, and visual.
"
" - To disable a map, set the 'nmap', 'imap', or 'vmap' entry to
"   an empty string or an empty list; or set fallback variable
"   (g:vim_web_hatch_google_define_seq) to an empty string.
"
" - Default value: If neither g:vim_web_hatch_maps["define"]
"   nor g:vim_web_hatch_google_define_seq is defined, and if
"   the sequence is not already mapped, defaults to:
"
"     <Leader>D

function! s:place_binding_search_web_for_definition()
  " [lb]: Almost same as s:place_binding_search_web_for_selection, above,
  " but with `define+` added.
  let l:n_cmd = ":call embrace#browser#web_open_url('https://www.google.com/search?q=define+<C-R><C-W>', 0)<CR>"
  let l:i_cmd = "<C-O>" .. n_cmd
  " SAVVY: C-U clears the command line, which contains cruft, e.g., '<,'>
  " - gv selects the previous Visual area.
  " - y yanks the selected text into the default register.
  " - <Ctrl-R>" puts the yanked text into the command line.
  let l:v_cmd =
    \ " :<C-U>" ..
    \ "<CR>gvy" ..
    \ ":<C-U>call embrace#browser#web_open_url('https://www.google.com/search?q=define+<C-R>\"', 0)<CR>"

  " Traditional default: \D opens browser to Google define of selected text.
  call embrace#multimap#create_maps(
    \ "define",
    \ "vim_web_hatch_google_define_seq",
    \ "<Leader>D",
    \ l:n_cmd,
    \ l:i_cmd,
    \ l:v_cmd)
endfunction

" -------------------------------------------------------------------

" ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
" Open selected URL — Command maps
" ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

" USAGE:
"
" Open the URL under the cursor or selected.
"
" - To define the map sequences, use g:vim_web_hatch_maps["open"],
"   e.g.,
"
"     let g:vim_web_hatch_maps = {
"       \   'open':
"       \   {
"       \     'nmap': [ '<Leader>T', 'gW' ],
"       \     'imap': '<Leader>T',
"       \     'vmap': '<Leader>T',
"       \   },
"       ...
"
" - Or simplify the config if you want the same sequence used for all
"   three modes, e.g.,
"
"     let g:vim_web_hatch_maps = {
"       \   'open': '<Leader>T',
"       ...
"
" - Alternatively, if g:vim_web_hatch_maps["open"] is not defined,
"   you can use g:vim_web_hatch_open_url_seq instead, e.g.,
"
"     let g:vim_web_hatch_open_url_seq = '<Leader>T'
"
"   and that sequence will be used to create maps for each of the
"   three modes, normal, insert, and visual.
"
" - To disable a map, set the 'nmap', 'imap', or 'vmap' entry to
"   an empty string or an empty list; or set fallback variable
"   (g:vim_web_hatch_open_url_seq) to an empty string.
"
" - Default value: If neither g:vim_web_hatch_maps["open"]
"   nor g:vim_web_hatch_open_url_seq is defined, and if
"   the sequence is not already mapped, defaults to:
"
"     <Leader>T

" ALTLY: We could call `sensible-browser` or `sensible-open` instead
" (but we'll use s:web_open_url for portability).
" - Here's an alternative implementation:
"   “ Note that we must escape the shell command argument, e.g., if you select this URL:
"   “   http://example.com/#foo
"   “ a simple mapping like:
"   “   vnoremap <Leader>T y:!sensible-browser '<C-R>"'<CR>
"   “ will fail on the pound sign/octothorpe/hash symbol, complaining
"   “   E499: Empty file name for '%' or '#', only works with ':p:h'
"   if executable("sensible-browser")
"     “ Linux (or at least Debian) built-in.
"     vnoremap <silent> <Leader>T y:execute '!sensible-browser ' .. shellescape('<C-R>"', 1)<CR>
"   elseif executable("sensible-open")
"     “ https://github.com/landonb/sh-sensible-open#☔
"     vnoremap <silent> <Leader>T y:execute '!sensible-open ' .. shellescape('<C-R>"', 1)<CR>
"   else
"     vnoremap <silent> <Leader>T y:call embrace#browser#web_open_url('<C-r>"', 0)<CR>
"   endif

function! s:place_binding_web_open_url()
  let l:n_cmd = ":call embrace#browser#web_open_url('', 0)<CR>"
  let l:i_cmd = "<C-O>" .. n_cmd
  let l:v_cmd = "y:call embrace#browser#web_open_url('<C-r>\"', 0)<CR>"

  " Traditional default: <Leader>T opens URL under cursor/selected.
  call embrace#multimap#create_maps(
    \ "open",
    \ "vim_web_hatch_open_url_seq",
    \ "<Leader>T",
    \ l:n_cmd,
    \ l:i_cmd,
    \ l:v_cmd)
endfunction

" -------------------------------------------------------------------

" ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
" Open selected URL — Command maps
" ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

" USAGE:
"
" Open the URL under the cursor or selected in incognito/private window.
"
" - To define the map sequences, use g:vim_web_hatch_maps["incognito"],
"   e.g.,
"
"     let g:vim_web_hatch_maps = {
"       \   'incognito': {
"       \     'nmap': '<Leader>P',
"       \     'imap': '<Leader>P',
"       \     'vmap': '<Leader>P',
"       \   },
"       ...
"
" - Or simplify the config if you want the same sequence used for all
"   three modes, e.g.,
"
"     let g:vim_web_hatch_maps = {
"       \   'incognito': '<Leader>P',
"       ...
"
" - Alternatively, if g:vim_web_hatch_maps["incognito"] is not defined,
"   you can use g:vim_web_hatch_open_incognito_seq instead, e.g.,
"
"     let g:vim_web_hatch_open_incognito_seq = '<Leader>P'
"
"   and that sequence will be used to create maps for each of the
"   three modes, normal, insert, and visual.
"
" - To disable a map, set the 'nmap', 'imap', or 'vmap' entry to
"   an empty string or an empty list; or set fallback variable
"   (g:vim_web_hatch_open_incognito_seq) to an empty string.
"
" - Default value: If neither g:vim_web_hatch_maps["incognito"]
"   nor g:vim_web_hatch_open_incognito_seq is defined, and if
"   the sequence is not already mapped, defaults to:
"
"     <Leader>P
"
" HSTRY/2024-12-08: Original landonb/dubs_web_hatch plugin used `nmap g!`
" and did not define insert or visual mode maps to open URL in incognito
" window. But we've changed the default to <Leader>P for better parity
" with the other maps (which are all <Leader>{some-uppercase-character},
" and which each define all three mode maps).
" - Given the new configurability feature (g:vim_web_hatch_maps), the
"   author expects/encoursages each user to decide for themselves what
"   key sequences and which modes they want to map. So it really should
"   not matter too much what the default is.

function! s:place_binding_web_open_url_incognito()
  let l:n_cmd = ":call embrace#browser#web_open_url('', 1)<CR>"
  let l:i_cmd = "<C-O>" .. n_cmd
  let l:v_cmd = "y:call embrace#browser#web_open_url('<C-r>\"', 1)<CR>"

  " Defaults <Leader>P to open URL under cursor/selected in private window.
  call embrace#multimap#create_maps(
    \ "incognito",
    \ "vim_web_hatch_open_incognito_seq",
    \ "<Leader>P",
    \ l:n_cmd,
    \ l:i_cmd,
    \ l:v_cmd)
endfunction

" -------------------------------------------------------------------

" ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
" Public setup function — Call from your user code to setup this plugin
" ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

function! VimWebHatchSetup() abort
  " The following USAGE examples assume config dictionary setup thusly:
  "   let g:vim_web_hatch_maps = {}
  "   let g:vim_web_hatch_maps.open = {}
  "   let g:vim_web_hatch_maps.define = {}
  "   let g:vim_web_hatch_maps.search = {}
  "   let g:vim_web_hatch_maps.incognito = {}

  " Open URL under cursor/selected in browser.
  " - USAGE: E.g. (mnemonic: "open browser _T_ab"):
  "     " For normal, insert, and visual modes:
  "     let g:vim_web_hatch_open_url_seq = "<Leader>T"
  "     " For select modes:
  "     let g:vim_web_hatch_maps.open.nmap = "<Leader>T"
  "     let g:vim_web_hatch_maps.open.imap = "<Leader>T"
  "     let g:vim_web_hatch_maps.open.vmap = "<Leader>T"
  call <SID>place_binding_web_open_url()

  " Run Google define on term under cursor/selected.
  " - USAGE: E.g. (mnemonic: "_D_efine"):
  "     " For normal, insert, and visual modes:
  "     let g:vim_web_hatch_google_define_seq = "<Leader>D"
  "     " For select modes:
  "     let g:vim_web_hatch_maps.define.nmap = "<Leader>D"
  "     let g:vim_web_hatch_maps.define.imap = "<Leader>D"
  "     let g:vim_web_hatch_maps.define.vmap = "<Leader>D"
  call <SID>place_binding_search_web_for_definition()

  " Run Google search on term under cursor/selected.
  " - USAGE: E.g. (mnemonic: "search _W_eb"):
  "     " For normal, insert, and visual modes:
  "     let g:vim_web_hatch_google_search_seq = "<Leader>W"
  "     " For select modes:
  "     let g:vim_web_hatch_maps.search.nmap = "<Leader>W"
  "     let g:vim_web_hatch_maps.search.imap = "<Leader>W"
  "     let g:vim_web_hatch_maps.search.vmap = "<Leader>W"
  call <SID>place_binding_search_web_for_selection()

  " Open URL under cursor/selected in incognito window.
  " - USAGE: E.g. (mnemonic: "open _P_rivate window"):
  "     " For normal, insert, and visual modes:
  "     let g:vim_web_hatch_open_incognito_seq = "<Leader>P"
  "     " For select modes:
  "     let g:vim_web_hatch_maps.incognito.nmap = "<Leader>P"
  "     let g:vim_web_hatch_maps.incognito.imap = "<Leader>P"
  "     let g:vim_web_hatch_maps.incognito.vmap = "<Leader>P"
  call <SID>place_binding_web_open_url_incognito()
endfunction

" USAGE: Set g:vim_web_hatch_* variable(s) to your liking, then
" call setup function to wire 'em all:
"
"   call VimWebHatchSetup()

