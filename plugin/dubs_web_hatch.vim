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

" MAYBE/2020-05-10 14:04: Add g:global_variable for choosing URL opener,
" or make distro-specific choice, e.g.,
"
"   if (match(system('cat /proc/version'), 'Ubuntu') >= 0)
"     let g:dubs_web_hatch_open = 'sensible-browser'
"   ...

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

" - The following web_open_url() function is inspired by:
"       https://stackoverflow.com/a/53817071
"   albeit I fixed an issue with shellescape being called before checking for
"   the empty string (which shellescape would put quotes around, so it'd no
"   longer be empty).
"   - I also swapped `open` for `sensible-browser`. `open` is for macOS. (And
"     `xdg-open` is more for Linux, but `sensible-browser` is more literal.)
" - That SO post was (possibly) inspired by (or at least referenced from):
"      https://stackoverflow.com/a/9459366
"   which tells users to try Vim's builtin `gx`, but I have issues with `gx`.
" - See also another plugin I found:
"       https://github.com/henrik/vim-open-url
"   Which uses more rebost regex as described by the Markdown author:
"       https://daringfireball.net/2010/07/improved_regex_for_matching_urls
"   But so far I've run across no limitations with the simpler regex used here.
" - The (an)other plugin also claims to work when two URLs are on the same row, e.g.,
"       " http://example.com/#foo and http://example.com/?foo=bar#baz "
"   but when I tested, all I saw was the line being echoed, and nothing more.
"   - With the code herein, if 2 URLs are on the same line, the first is opened.
"   - Which is fine for my use case: I have URLs in notes files, but never two
"     on the same line, which -- without a magic open-URL function -- is useful
"     for copying a URL that you intend to paste to a browser, as you can just
"     copy the whole line (including newline) with a few keystrokes (and the
"     browser will strip leading and trailing whitespace when you paste).
"   - You also have to set the opener with the (an)other plugin, e.g.,
"       let g:open_url_browser="xdg-open"
"     which is probably something I could adapt here (because I think Linux
"     and macOS support `sensible-browser`, but not Windows).
" - There's also the Vim builtin `gx`, but I have issues with `gx` always
"   calling `wget` on the URL, no matter how I configure it.
"   - For instance, even when I specified the browser opener:
"       let g:netrw_browsex_viewer = "sensible-browser"
"     `gx` would still `wget` the resource first, and then open the temporary
"     download file path in my browser. Heh?!
"     - I also tried other vectors:
"       - This wgets the URL under cursor to /tmp/some-dir/, then replaces
"         my open file in Vim with a blank file (and Ctrl-j doesn't go back!):
"           let g:netrw_browsex_viewer = "xdg-open"
"       - This opens the downloaded resource to a GUI text editor (not Vim):
"           let g:netrw_browsex_viewer = "setsid xdg-open"
"       - This opens the dowloaded resource in my browser, with a temporary path,
"         e.g., file:///tmp/vuzpUag/116, and also replaces current Vim buffer with
"         a new one (closing/wiping the previous buffer, so Ctrl-J does nothing):
"           let g:netrw_browsex_viewer = "sensible-browser"
" - This leaves only one feature that the (an)other plugin offers, which is
"   to handle special URLs, like Spotify, e.g.,
"       spotify:track:6JEK0CvvjDjjMUBFoXShNZ
"   which is novel, but not a feature that I see myself starting to use.
function! s:web_open_url()
  let s:uri = matchstr(getline("."), '[a-z]*:\/\/[^ >,;()]*')
  if s:uri != ""
    "  echom "Found URI: " . s:uri
    " Add shell-appropriate quotes around the URL.
    let s:uri = shellescape(s:uri, 1)
    silent exec "!sensible-browser " . s:uri
    " (lb): SO post calls redraw, but seems unnecessary.
    "    :redraw!
  else
    echo "No URI found in line."
  endif
endfunction

function! s:reset_binding_web_open_url()
  silent! unmap gW

  silent! unmap <Leader>T
  silent! iunmap <Leader>T
  silent! vunmap <Leader>T
endfunction

function! s:place_binding_web_open_url()
  call <SID>reset_binding_web_open_url()

  " 2020-05-10: I (finally) learned about Vim's builtin `gf` (and `gF`), and now
  " I'm thinking that maybe `gW` makes sense ("go Web"), which is not mapped by Vim.
  " - So trying gW, but leaving historic \T that's been wired for a spell (albeit broken).
  "   However, the <Leader>T hooks are still nice to have because they work in all modes.
  nnoremap gW :call <SID>web_open_url()<CR>

  nnoremap <Leader>T <SID>web_open_url()<CR>
  inoremap <Leader>T <C-O>:call <SID>web_open_url()<CR>
  " Note that we must escape the shell command argument, e.g., if you select this URL:
  "   http://example.com/#foo
  " a simple mapping like:
  "  vnoremap <Leader>T y:!sensible-browser '<C-R>"'<CR>
  " will fail on the pound sign/octothorpe/hash symbol, complaining
  "   E499: Empty file name for '%' or '#', only works with ":p:h"
  vnoremap <silent> <Leader>T y:execute "!sensible-browser " . shellescape('<C-R>"', 1)<CR>
endfunction

call <SID>place_binding_web_open_url()

