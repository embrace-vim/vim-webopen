" vim:tw=0:ts=2:sw=2:et:norl
" Author: Landon Bouma <https://tallybark.com/>
" Project: https://github.com/embrace-vim/vim-web-hatch#🐣
" License: GPLv3

" -------------------------------------------------------------------

" USAGE: After editing this plugin, you can reload it on the fly with
"        https://github.com/landonb/vim-source-reloader#↩️
" - Uncomment this `unlet` (or disable the `finish`) and hit <F9>.
"
" silent! unlet g:loaded_vim_web_hatch_autoload_browser

if exists("g:loaded_vim_web_hatch_autoload_browser") || &cp

  finish
endif

let g:loaded_vim_web_hatch_autoload_browser = 1

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
"        ~/.vim/pack/landonb/start/vim-netrw-link-resolve/net.
let s:vim_web_hatch_plugin_path = fnamemodify(resolve(expand('<sfile>:p')), ':h')

function! s:macOS_which_browser()
  " 2020-09-01: (lb): Not worrying about path separator.
  "             (Vim handles, right? That, or '/' works on Windows.)
  " REFER: fnamemodify(..., ':h'): See: :h filename-modifiers
  "        - ':h:h' removes 'autoload/embrace/' to get project root.
  let l:plugbin = fnamemodify(s:vim_web_hatch_plugin_path, ':h:h') . '/' . 'bin'
  "  echom l:plugbin
  let l:whicher = l:plugbin . '/' . 'macOS-which-browser'
  " REFER: See :h feature-list / Note that Cygwin is 'win32unix'.
  if has('win32')
    let l:syscmmd = l:whicher . ' 2>NUL'
  else
    let l:syscmmd = l:whicher . ' 2>/dev/null'
  endif
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
function! embrace#browser#web_open_url(suggested_uri, incognito)
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

