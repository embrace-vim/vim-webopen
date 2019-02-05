" Project Page: https://github.com/landonb/dubs_web_hatch
" License: GPLv3
" vim:tw=0:ts=2:sw=2:et:norl:ft=vim
" ----------------------------------------------------------------------------
" Copyright © 2019 Landon Bouma.
"
" This file is part of Dubs Vim.
"
" Dubs Vim is free software: you can redistribute it and/or
" modify it under the terms of the GNU General Public License
" as published by the Free Software Foundation, either version
" 3 of the License, or (at your option) any later version.
"
" Dubs Vim is distributed in the hope that it will be useful,
" but WITHOUT ANY WARRANTY; without even the implied warranty
" of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See
" the GNU General Public License for more details.
"
" You should have received a copy of the GNU General Public License
" along with Dubs Vim. If not, see <http://www.gnu.org/licenses/>
" or write Free Software Foundation, Inc., 51 Franklin Street,
"                     Fifth Floor, Boston, MA 02110-1301, USA.
" ===================================================================

if exists("g:plugin_dubs_web_hatch") || &cp
  finish
endif
let g:plugin_dubs_web_hatch = 1

" ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
" Search Web for Selection, or Word Under Cursor
" ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

function! s:reset_binding_search_web_for_selection()
  silent! unmap <Leader>W
  silent! iunmap <Leader>W
  silent! vunmap <Leader>W
endfunction

" E.g.,
"   https://www.google.com/search?q=<TERM>
function! s:place_binding_search_web_for_selection()
  call <SID>reset_binding_search_web_for_selection()

  " [lb]: Cannot not specify http, i.e., Chrome tries to open term as
  " URL, rather than send to default search engine, when invoked thru
  " sensible-browser (as opposed to typing a term in the location bar
  " and the browser deciding if it is a URL or if it is search text).
  noremap <silent> <Leader>W
    \ :!sensible-browser 'https://www.google.com/search?q=<C-R><C-W>'
    \ &> /dev/null<CR><CR>
  inoremap <silent> <Leader>W
    \ <C-O>:!sensible-browser 'https://www.google.com/search?q=<C-R><C-W>'
    \ &> /dev/null<CR><CR>
  " Interesting: C-U clears the command line, which contains cruft, e.g., '<,'>
  " gv selects the previous Visual area.
  " y yanks the selected text into the default register.
  " <Ctrl-R>" puts the yanked text into the command line.
  vnoremap <silent> <Leader>W :<C-U>
    \ <CR>gvy
    \ :!sensible-browser 'https://www.google.com/search?q=<C-R>"'
    \ &> /dev/null<CR><CR>
endfunction

call <SID>place_binding_search_web_for_selection()

" ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
" Search Web for Definition of Selection, or Word Under Cursor
" ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

function! s:reset_binding_search_web_for_definition()
  silent! unmap <Leader>D
  silent! iunmap <Leader>D
  silent! vunmap <Leader>D
endfunction

" E.g.,
"   https://www.google.com/search?q=define+<TERM>
function! s:place_binding_search_web_for_definition()
  call <SID>reset_binding_search_web_for_definition()

  " [lb]: Copied-paste of other binding fcns., except `define+` addition.
  noremap <silent> <Leader>D
    \ :!sensible-browser 'https://www.google.com/search?q=define+<C-R><C-W>'
    \ &> /dev/null<CR><CR>
  inoremap <silent> <Leader>D
    \ <C-O>:!sensible-browser 'https://www.google.com/search?q=define+<C-R><C-W>'
    \ &> /dev/null<CR><CR>
  vnoremap <silent> <Leader>D :<C-U>
    \ <CR>gvy
    \ :!sensible-browser 'https://www.google.com/search?q=define+<C-R>"'
    \ &> /dev/null<CR><CR>
endfunction

call <SID>place_binding_search_web_for_definition()

" ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
" Open selected URL
" ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

function! s:reset_binding_web_open_url()
  silent! unmap <Leader>T
  silent! iunmap <Leader>T
  silent! vunmap <Leader>T
endfunction

function! s:place_binding_web_open_url()
  call <SID>reset_binding_web_open_url()

  " [lb]: Copied-paste of other binding fcns., except `define+` addition.
  noremap <silent> <Leader>T
    \ :!sensible-browser '<C-R><C-W>'
    \ &> /dev/null<CR><CR>
  inoremap <silent> <Leader>T
    \ <C-O>:!sensible-browser '<C-R><C-W>'
    \ &> /dev/null<CR><CR>
  vnoremap <silent> <Leader>T :<C-U>
    \ <CR>gvy
    \ :!sensible-browser '<C-R>"'
    \ &> /dev/null<CR><CR>
endfunction

call <SID>place_binding_web_open_url()

