################################
Open URLs in external browser 🐣
################################

Open URLs from Vim. Or search the web, define words, or use an incognito
(private) window.

Use this plugin to define your choice of normal, insert, and visual mode
commands and their key sequences.

Initialization
==============

Your Vim config must initialize the plugin, otherwise it won't do anything.

Call this from your Vim config:

.. code-block::

    call g:embrace#webopen#CreateMaps()

See `Command Configuration`_ below for details on how to choose which
commands to enable, and how to specify which key sequences to use.

Default Commands
================

Without any configuration, ``vim-webopen`` will configure the following
maps in each of three separate modes — normal mode, insert mode, and visual
mode. ``vim-webopen`` will not redefine an existing command. See the next
section for customizing or disabling each command map.


==============    =========================================================================
Command           Description
--------------    -------------------------------------------------------------------------
``<Leader>T``     Opens a new browser window with the location of the
                  URL under the cursor. Similar to Vim's builtin ``gf``
                  command that opens the file path found under the
                  cursor. Works from normal and insert mode on the
                  URL under the cursor, or from visual mode on the
                  selected text.
                  (Mnemonic: new Tab)
--------------    -------------------------------------------------------------------------
``<Leader>D``     Opens a browser tab and loads the definition of the
                  word under the cursor (normal or insert mode) or the
                  selected text (visual mode). (Currently searches
                  Google, but please submit a PR if you'd like to make
                  the definition lookup configurable.)
                  (Mnemonic: Define)
--------------    -------------------------------------------------------------------------
``<Leader>W``     Opens a browser tab and Google-searches the word
                  under the cursor (normal or insert mode) or the
                  selected text (visual mode). (Please submit a PR
                  if you'd like to make the search engine configurable.)
                  (Mnemonic: Web search)
--------------    -------------------------------------------------------------------------
``<Leader>P``     Like ``<Leader>T``, but opens the location in an
                  incognito (aka private) browser window. Works from
                  normal and insert mode on the URL under the cursor,
                  or from visual mode on the selected text.
                  (Mnemonic: Private window)
==============    =========================================================================

Command Configuration
=====================

OPTION 1
--------

Option 1: Define individual global variables for each feature.

- Using this approach will create three maps for each key sequence,
  one each in the three modes: normal, insert, and visual.

  - See Option 2 (next) to specify a different sequence for each mode.

- Set a variable to the empty string to disable the maps for that feature.

For example, the default commands (listed above) are configured like this:

.. code-block::

    let g:vim_webopen_open_location_seq = "<Leader>T"
    let g:vim_webopen_google_define_seq = "<Leader>D"
    let g:vim_webopen_google_search_seq = "<Leader>W"
    let g:vim_webopen_open_incognito_seq = "<Leader>P"

    call g:embrace#webopen#CreateMaps()

OPTION 2
--------

Option 2: Define a single global variable Dictionary.

- This option supports different key sequences for the
  different modes, and it lets you define multiple maps
  using different key sequences for the same command.

  - E.g., if you want the basic "open" command to work from
    either ``<Leader>T`` or from ``gW`` (to match the ``gf`` command),
    you could define:

.. code-block::

    let g:vim_webopen_maps = { "open": { "nmap": [ "<Leader>T", "gW" ] } }

- To inhibit maps for a specific feature, set the top-level
  value to an empty dictionary, e.g., to skip the incognito
  feature altogether, you could set:

.. code-block::

    let g:vim_webopen_maps = { "incognito": {} }

- Or, to inhibit maps for a specific mode, set the nested dictionary
  value to an empty string or to an empty list.

  For example, this setting will only define an "open" command in visual
  mode, and it will skip the normal and insert mode maps for open URL:

.. code-block::

    let g:vim_webopen_maps =
      \ { "open": { "nmap": "", "imap": [], "vmap": "<Leader>T" } }

- Note the plugin uses ``g:vim_webopen_maps`` if a top-level key
  is found (like "open"). But it will look for the Option 1
  variable if the top-level key is missing.

  - And if the Option 1 variable isn't set, it'll use the
    default key sequence shown above (in `Default Commands`_).

  - So this plugin is opt-out, not opt-in; but it no case will it
    clobber an existing map.

For example, this is how the author configures this plugin — I add
``gW`` for "open", because it's similar to the ``gf`` builtin command; and
I change the incognito key sequence to ``g!`` and only enable it from
visual mode:

.. code-block::

    let g:vim_webopen_maps =
      \ {
      \   "open":
      \     {
      \       "nmap": [ "<Leader>T", "gW" ],
      \       "imap": "<Leader>T",
      \       "vmap": "<Leader>T",
      \     },
      \   "define": "<Leader>D",
      \   "search": "<Leader>W",
      \   "incognito": { "nmap": "g!" },

    call g:embrace#webopen#CreateMaps()

Tip: If you'd like to avoid a long dictionary definition, you
can build the dictionary one key-value at a time.

- For example, here's the same dictionary as the previous
  example but defined one-by-one:

.. code-block::

    let g:vim_webopen_maps = {}

    let g:vim_webopen_maps.open = {}
    let g:vim_webopen_maps.define = {}
    let g:vim_webopen_maps.search = {}
    let g:vim_webopen_maps.incognito = {}

    let g:vim_webopen_maps.open.nmap = [ "<Leader>T", "gW" ]
    let g:vim_webopen_maps.open.imap = "<Leader>T"
    let g:vim_webopen_maps.open.vmap = "<Leader>T"

    let g:vim_webopen_maps.define.nmap = "<Leader>D"
    let g:vim_webopen_maps.define.imap = "<Leader>D"
    let g:vim_webopen_maps.define.vmap = "<Leader>D"

    let g:vim_webopen_maps.search.nmap = "<Leader>W"
    let g:vim_webopen_maps.search.imap = "<Leader>W"
    let g:vim_webopen_maps.search.vmap = "<Leader>W"

    let g:vim_webopen_maps.incognito.nmap = "g!"

    call g:embrace#webopen#CreateMaps()

.. |vim-webopen-config| replace:: ``https://github.com/DepoXy/depoxy/blob/1.7.5/home/.vim/pack/DepoXy/start/vim-depoxy/plugin/vim-webopen-config.vim``
.. _vim-webopen-config: https://github.com/DepoXy/depoxy/blob/1.7.5/home/.vim/pack/DepoXy/start/vim-depoxy/plugin/vim-webopen-config.vim

(You can see a real-world implementation in
|vim-webopen-config|_.)

Browser Configure
=================

Default Browser
---------------

On Linux (Debian), this plugin call ``sensible-browser --version`` to
determine which browser to use.

- Use the ``$BROWSER`` environ to set your default browser.

  - E.g., include this in your ``~/.bashrc`` if you prefer Chrome::

      export BROWSER=/usr/bin/google-chrome

  - For the best documentation on ``sensible-browser``, see the source,
    which you might find at::

      /usr/bin/sensible-browser

On macOS, this plugin reads the user's ``LaunchServices`` property list
looking for the default browser to use.

- Run the browser you want to be the default, and look for an option
  within the browser to set it as the default.

- Or, better yet, install ``finicky`` to define the default browser,
  browser behavior, and to associate different browsers with
  different URLs:

  https://github.com/johnste/finicky

Please feel free to open a pull request to add support for additional OSes,
or to offer additional help.

Tab or Window
-------------

By default, each command opens a new browser tab in new window.

- To instead prefer opening a new tab in an existing window,
  set the following global variable to nonzero, e.g.,::

    g:vim_webopen_use_tab = 1

User Profile
------------

By default, when Chrome is opened, the default user profile is used.

- To instead open a window using the most recently used profile,
  set the following global variable to nonzero, e.g.,::

    g:vim_webopen_mru_profile = 1

Supported Browsers
------------------

This plugin works with the following browsers:

- On Debian: Google Chrome, Chromium, and Mozilla Firefox.

- On macOS: Google Chrome, Mozilla Firefox, and Apple Safari.

Note that Safari does not accept command line arguments, so it does not
respect tab vs. window, nor can it open a location in incognito mode.

Please feel free to open a pull request to add support for additional browsers.

Installation
============

.. |help-packages| replace:: ``:h packages``
.. _help-packages: https://vimhelp.org/repeat.txt.html#packages

.. |INSTALL.md| replace:: ``INSTALL.md``
.. _INSTALL.md: INSTALL.md

Take advantage of Vim's packages feature (|help-packages|_)
and install under ``~/.vim/pack``, e.g.,:

.. code-block::

  mkdir -p ~/.vim/pack/embrace-vim/start
  cd ~/.vim/pack/embrace-vim/start
  git clone https://github.com/embrace-vim/vim-webopen.git

  " Build help tags
  vim -u NONE -c "helptags vim-webopen/doc" -c q

- Alternatively, install under ``~/.vim/pack/embrace-vim/opt`` and call
  ``:packadd vim-webopen`` to load the plugin on-demand.

For more installation tips — including how to easily keep the
plugin up-to-date — please see |INSTALL.md|_.

Attribution
===========

.. |embrace-vim| replace:: ``embrace-vim``
.. _embrace-vim: https://github.com/embrace-vim

.. |@landonb| replace:: ``@landonb``
.. _@landonb: https://github.com/landonb

The |embrace-vim|_ logo by |@landonb|_ contains
`coffee cup with straw by farra nugraha from Noun Project
<https://thenounproject.com/icon/coffee-cup-with-straw-6961731/>`__
(CC BY 3.0).

