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
  let l:n_cmd = ":call <SID>web_open_url('https://www.google.com/search?q=<C-R><C-W>', 0)<CR>"
  let l:i_cmd = "<C-O>" .. n_cmd
  " SAVVY: C-U clears the command line, which contains cruft, e.g., '<,'>
  " - gv selects the previous Visual area.
  " - y yanks the selected text into the default register.
  " - <Ctrl-R>" puts the yanked text into the command line.
  let l:v_cmd =
    \ " :<C-U>" ..
    \ "<CR>gvy" ..
    \ ":<C-U>call <SID>web_open_url('https://www.google.com/search?q=<C-R>\"', 0)<CR>"

  " Traditional default: \W opens browser to Google search of selected text.
  call s:create_maps(
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
  let l:n_cmd = ":call <SID>web_open_url('https://www.google.com/search?q=define+<C-R><C-W>', 0)<CR>"
  let l:i_cmd = "<C-O>" .. n_cmd
  " SAVVY: C-U clears the command line, which contains cruft, e.g., '<,'>
  " - gv selects the previous Visual area.
  " - y yanks the selected text into the default register.
  " - <Ctrl-R>" puts the yanked text into the command line.
  let l:v_cmd =
    \ " :<C-U>" ..
    \ "<CR>gvy" ..
    \ ":<C-U>call <SID>web_open_url('https://www.google.com/search?q=define+<C-R>\"', 0)<CR>"

  " Traditional default: \D opens browser to Google define of selected text.
  call s:create_maps(
    \ "define",
    \ "vim_web_hatch_google_define_seq",
    \ "<Leader>D",
    \ l:n_cmd,
    \ l:i_cmd,
    \ l:v_cmd)
endfunction

" -------------------------------------------------------------------

" ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
" Open selected URL — Utility functions
" ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

" INERT/2020-05-10: Add g:global_variable for choosing URL opener,
" possibly with distro-specific fallback, e.g.,
"
"   if !exists("g:vim_web_hatch_open")
"     if (match(system('cat /proc/version'), 'Ubuntu') >= 0)
"       let g:vim_web_hatch_open = 'sensible-browser'
"     ...
"
" - Except code calls `sensible-browser --version`, which wouldn't
"   be reliable; and how would we know what options to use to open
"   an incognito window, or to open a new window vs. new tab?
"
" In any case, on macOS uses `open` command, otherwise it checks
" the command exists via `executable('sensible-browser')`, which
" seems robust enough.

" ***

" https://stackoverflow.com/questions/4976776/how-to-get-path-to-the-current-vimscript-being-executed
" Path to this script's directory: get absolute path; resolve symlinks; get directory name.
" - (lb) Running at script/source level, because if I <F9> reload this script,
"        I see different (incorrect) path (of another plugin,
"        ~/.vim/pack/landonb/start/vim-netrw-link-resolve/net).
let s:vim_web_hatch_plugin_path = fnamemodify(resolve(expand('<sfile>:p')), ':h')

function! s:macOS_which_browser()
  " 2020-09-01: (lb): Not worrying about path separator.
  "             (Vim handles, right? That, or '/' works on Windows.)
  " Ref: fnamemodify(..., ':h'): See: :h filename-modifiers.
  let l:plugbin = fnamemodify(s:vim_web_hatch_plugin_path, ':h') . '/' . 'bin'
  "  echom l:plugbin
  let l:whicher = l:plugbin . '/' . 'macOS-which-browser'
  " MEH: On Windows, use 2>NUL instead.
  let l:syscmmd = l:whicher . ' 2>/dev/null'
  "  echom l:whicher
  let l:handler = system(l:syscmmd)
  " Hrmm, don't see this set like I'd expect on Linux:
  "   echom v:shell_error
  "  echom l:handler

  return l:handler
endfunction

" ***

function! s:default_browser()
  if has('macunix')
    let l:handler = <SID>macOS_which_browser()

    if l:handler == "com.google.chrome"

      return "chrome"
    elseif l:handler == "org.mozilla.firefox"

      return "firefox"
    elseif l:handler == "com.apple.safari"
      " /Applications/Sarari.app/Contents/MacOS/Safari
      " Note that Safari (a Cocoa app, not a CLI app) does not accept arguments.

      return "safari"
    elseif l:handler == "com.googlecode.iterm2"

      return ""
    elseif l:handler == "net.kassett.finicky"
      " https://github.com/johnste/finicky
      " Finicky is used to customize the default browser and options for
      " specific applications and URLs, but Finicky itself doesn't support
      " options, so fallback on Chrome.
      " - INERT: We could add, e.g., BROWSER environ to let user set a
      "          different fallback default browser. If any user cares.

      return "chrome"
    endif
  elseif executable("sensible-browser")
    " Linux.
    " (lb): `echo $BROWSER` shows nothing, so ask sensible-browser, I suppose.
    let l:handler = system('sensible-browser --version')

    " Use \(^\|\n\) because Chromium's --version's first line is 'Using PPAPI flash.'
    if l:handler =~ '\(^\|\n\)Google Chrome '
      " /usr/bin/google-chrome-stable

      return "chrome"
    elseif l:handler =~ '\(^\|\n\)Chromium '
      " /usr/bin/chromium-browser

      return "chrome"
    elseif l:handler =~ '\(^\|\n\)Mozilla Firefox '
      " /usr/bin/firefox

      return "firefox"
    endif
  endif

  return ""
endfunction

" ***

function! s:browopts_incognito(which_browser, options, incognito)
  let l:options = a:options

  if a:incognito == 1
    if a:which_browser == 'chrome'
      let l:options = l:options . "--incognito "
    elseif a:which_browser == 'firefox'
      let l:options = l:options . "--private-window "
    endif
  endif

  return l:options
endfunction

" ***

function! s:browopts_new_window(which_browser, options)
  let l:options = a:options

  if !exists("g:vim_web_hatch_use_tab") || g:vim_web_hatch_use_tab == 0
    if a:which_browser == 'chrome' || a:which_browser == 'firefox'
      let l:options = l:options . "--new-window "
    endif
  endif

  return l:options
endfunction

" ***

function! s:browopts_profile_dir(which_browser, options)
  let l:options = a:options

  if !exists("g:vim_web_hatch_mru_profile") || g:vim_web_hatch_mru_profile == 0
    if a:which_browser == 'chrome'
      let l:options = l:options . "--profile-directory=Default "
    endif
  endif

  return l:options
endfunction

" ***

" - Sending arguments to macOS browser requires two options to `open`.
"   - A basic `open -a 'Google Chrome' URL` opens a URL in new tab of
"     existing window, akin to a basic `sensible-browser URL` on Linux.
"   - The `open` has an `--args` option to precede pass-through options,
"     but you also need to add `-n` so open tries to open a new Chrome
"     instance, which Chrome will capture and kill, and pass control
"     back to the running instance, "but this is necessary to force
"     arguments to be read", according and thanks to georgegarside.
"     E.g.,
"       open -na 'Google Chrome' --args --new-window <location>
"     https://apple.stackexchange.com/a/305902/388088
"   - Note that the application is necessary, e.g.,
"       open -n --args --new-window <location>
"     will not work as intended.
"     - Note also order matters: Put <location> last.
function! s:browser_cmd(which_browser, options)
  let l:browpener = ""

  if has('macunix')
    if a:options == ""
      let l:browpener = "open -a"
    else
      " See comments before function, necessary for --args to be effective.
      let l:browpener = "open -na"
    endif
    if a:which_browser == 'chrome'
      let l:browpener = l:browpener . " 'Google Chrome'"
    elseif a:which_browser == 'firefox'
      let l:browpener = l:browpener . " 'Firefox'"
    elseif a:which_browser == 'safari'
      let l:browpener = l:browpener . " 'Safari'"
    endif
    if a:options != ""
      let l:browpener = l:browpener . " --args"
    endif
  elseif executable("sensible-browser")
    let l:browpener = "sensible-browser"
  endif
  
  return l:browpener
endfunction

" ***

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
"       ' http://example.com/#foo and http://example.com/?foo=bar#baz '
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
"       let g:netrw_browsex_viewer = 'sensible-browser'
"     `gx` would still `wget` the resource first, and then open the temporary
"     download file path in my browser. Heh?!
"     - I also tried other vectors:
"       - This wgets the URL under cursor to /tmp/some-dir/, then replaces
"         my open file in Vim with a blank file (and Ctrl-j doesn't go back!):
"           let g:netrw_browsex_viewer = 'xdg-open'
"       - This opens the downloaded resource to a GUI text editor (not Vim):
"           let g:netrw_browsex_viewer = 'setsid xdg-open'
"       - This opens the dowloaded resource in my browser, with a temporary path,
"         e.g., file:///tmp/vuzpUag/116, and also replaces current Vim buffer with
"         a new one (closing/wiping the previous buffer, so Ctrl-J does nothing):
"           let g:netrw_browsex_viewer = 'sensible-browser'
" - This leaves only one feature that the (an)other plugin offers, which is
"   to handle special URLs, like Spotify, e.g.,
"       spotify:track:6JEK0CvvjDjjMUBFoXShNZ
"   which is novel, but not a feature that I see myself starting to use.
function! s:web_open_url(suggested_uri, incognito)
  let l:uri = s:use_suggested_uri_or_parse_line(a:suggested_uri)

  if l:uri == ""
    echom "No URI found in line."

    return
  endif

  call s:open_browser_window(l:uri, a:incognito)
endfunction

" ***

function! s:use_suggested_uri_or_parse_line(uri)
  if a:uri != ""

    return a:uri
  endif

  " SAVVY: \{-} is non-greedy *.
  " SAVVY: \@= is Vim look-ahead.
  " SAVVY: Because single quote ('), period (.), and comma (,)
  "        might follow URL in, say, a reST or Markdown document,
  "        allow them in the URL, but ignore if trailing
  "        (and use look-ahead to not include in matchstr).
  " TRYME:
  "  :echo matchstr('  "    https://tallybark.com, X ── │┐', '[a-z]*:\/\/[^ >;()\[\]]\{-}\([.,;)\]"'."'".']\?\($\|[[:space:]]\)\)\@=')
  " TRYME:
  "   >https://tallybark.com ──────────────────┐
  "    https://tallybark.com. ──────────────── │───────────────┐
  "    https://tallybark.com, ──────────────── │───────────────│┐
  "    https://tallybark.com; ──────────────── │┐              ││
  "   (https://tallybark.com) ──────────────── ││┬┬────────────││─┐
  "   [https://tallybark.com] ──────────────── ││││─┬─┬────────││─│─┐
  "   "https://tallybark.com" ──────────────── ││││─│─│────────││─│─│┐
  "   'https://tallybark.com' ──────────────── ││││─│─│────────││─│─││───┐
  "   https://www.google.com/maps/place/13%C2%B008'20.1%22S+72%C2%B018'06.1%22W/@-13.1389113,-72.3022458,239m/,, 
  "                                            ││││ │ ││       │├││─││───│─────────────────────────────────────┘
  return matchstr(getline("."), '[a-z]*:\/\/[^ >;()\[\]]\{-}\([.,;)\]"'."'".']\?\($\|[[:space:]]\)\)\@=')
endfunction

" ***

function! s:open_browser_window(uri, incognito)
  let l:which_browser = <SID>default_browser()

  " echom 'Open URL: ' . l:uri
  "   \ . ' / incognito: ' . a:incognito
  "   \ . ' / which_browser: ' . l:which_browser

  " Add shell-appropriate quotes around the URL.
  let l:uri = shellescape(a:uri, 1)

  let l:options = ""
  " Add private browsing flag, perhaps, depending on which command was called.
  let l:options = <SID>browopts_incognito(l:which_browser, l:options, a:incognito)
  " Add new window flag, usually, unless disabled via g:vim_web_hatch_use_tab.
  let l:options = <SID>browopts_new_window(l:which_browser, l:options)
  " Tell Chrome to use default user profile, unless g:vim_web_hatch_mru_profile.
  let l:options = <SID>browopts_profile_dir(l:which_browser, l:options)

  let l:browpener = <SID>browser_cmd(l:which_browser, options)

  " echom 'silent exec ' . '!' . l:browpener . ' ' . l:options . l:uri

  silent exec "!" . l:browpener . " " . l:options . l:uri

  " Even though 'silent' was used, when Vim is run in the terminal via EDITOR
  " (I notice it running Vim from dob), the screen goes blank. You might see
  " a blip of text, e.g., from sensible-browser, which says:
  "   Opening in existing browser session.
  " And without 'silent', you'll see the previous message, and also a prompt:
  "   Press ENTER or type command to continue
  " But with the silent, there's no prompt, and the message whizzes by so
  " fast sometimes you see it, and sometimes you don't. But you're always
  " left with a blank screen.
  " - If you insert text on the blank screen, you'll overwrite the existing
  "   buffer, and existing text will reappear as you type.
  " - But you're also still in normal mode, and pressing either
  "   Ctrl-L or `:redraw!` will fix things. And note you need the '!',
  "   which clears the screen first before redrawing, like, total reset.
  redraw!
endfunction

" -------------------------------------------------------------------

" MEH/2021-01-28: I ported previous macOS browser functionality to a new
" shell project, found at https://github.com/landonb/sh-sensible-open#☔
" but I'd rather not force plugin users to have to install that command.
" So rather than DRY this code (the functionality is the same, although
" one is Vim and the other is a POSIX command script), we'll keep both
" the code above and the new shell command. / So just realize (if you
" are me and the one maintaining these codebases) that this code is not
" DRY, and any changes you make here you might want to port to t'other.
"
" For the novelty of it, here's how we could simplify this plugin if we
" replaced the complicated web_open_url above with a simpler call to the
" shell command:
"
"   function! s:web_open_url(incognito)
"     let l:uri = matchstr(getline('.'), '[a-z]*:\/\/[^ >,;()]*')
"     if l:uri != ''
"       let l:uri = shellescape(l:uri, 1)
"       silent exec '!' . system('sensible-open' . ' ' . l:uri)
"       " Or if we need the raw command string for some reason:
"       "   let l:opencmd = system('_sensibleopen-format-open-command' . ' ' . l:uri)
"       "   exec '!' . l:opencmd
"     else
"       echo 'No URI found in line.'
"     endif
"   endfunction

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
"     vnoremap <silent> <Leader>T y:call <SID>web_open_url('<C-r>"', 0)<CR>
"   endif

function! s:place_binding_web_open_url()
  let l:n_cmd = ":call <SID>web_open_url('', 0)<CR>"
  let l:i_cmd = "<C-O>" .. n_cmd
  let l:v_cmd = "y:call <SID>web_open_url('<C-r>\"', 0)<CR>"

  " Traditional default: <Leader>T opens URL under cursor/selected.
  call s:create_maps(
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
  let l:n_cmd = ":call <SID>web_open_url('', 1)<CR>"
  let l:i_cmd = "<C-O>" .. n_cmd
  let l:v_cmd = "y:call <SID>web_open_url('<C-r>\"', 1)<CR>"

  " Defaults <Leader>P to open URL under cursor/selected in private window.
  call s:create_maps(
    \ "incognito",
    \ "vim_web_hatch_open_incognito_seq",
    \ "<Leader>P",
    \ l:n_cmd,
    \ l:i_cmd,
    \ l:v_cmd)
endfunction

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

