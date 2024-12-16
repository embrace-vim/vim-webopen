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

Installation is easy using the packages feature (see ``:help packages``).

To install the package so that it will automatically load on Vim startup,
use a ``start`` directory, e.g.,

.. code-block::

    mkdir -p ~/.vim/pack/embrace-vim/start
    cd ~/.vim/pack/embrace-vim/start

If you want to test the package first, make it optional instead
(see ``:help pack-add``):

.. code-block::

    mkdir -p ~/.vim/pack/embrace-vim/opt
    cd ~/.vim/pack/embrace-vim/opt

Clone the project to the desired path:

.. code-block::

    git clone https://github.com/embrace-vim/vim-webopen.git

If you installed to the optional path, tell Vim to load the package:

.. code-block:: vim

    :packadd! vim-webopen

Just once, tell Vim to build the online help:

.. code-block:: vim

    :Helptags

Then whenever you want to reference the help from Vim, run:

.. code-block:: vim

    :help vim-webopen

.. |vim-plug| replace:: ``vim-plug``
.. _vim-plug: https://github.com/junegunn/vim-plug

.. |Vundle| replace:: ``Vundle``
.. _Vundle: https://github.com/VundleVim/Vundle.vim

.. |myrepos| replace:: ``myrepos``
.. _myrepos: https://myrepos.branchable.com/

.. |ohmyrepos| replace:: ``ohmyrepos``
.. _ohmyrepos: https://github.com/landonb/ohmyrepos

Note that you'll need to update the repo manually (e.g., ``git pull``
occasionally).

- If you'd like to be able to update from within Vim, you could use
  |vim-plug|_.

  - You could then skip the steps above and register
    the plugin like this, e.g.:

.. code-block:: vim

    call plug#begin()

    " List your plugins here
    Plug 'embrace-vim/vim-webopen'

    call plug#end()

- And to update, call:

.. code-block:: vim

    :PlugUpdate

- Similarly, there's also |Vundle|_.

  - You'd configure it something like this:

.. code-block:: vim

    set nocompatible              " be iMproved, required
    filetype off                  " required

    " set the runtime path to include Vundle and initialize
    set rtp+=~/.vim/bundle/Vundle.vim
    call vundle#begin()
    " alternatively, pass a path where Vundle should install plugins
    "call vundle#begin('~/some/path/here')

    " let Vundle manage Vundle, required
    Plugin 'VundleVim/Vundle.vim'

    Plugin 'embrace-vim/vim-webopen'

    " All of your Plugins must be added before the following line
    call vundle#end()            " required
    filetype plugin indent on    " required
    " To ignore plugin indent changes, instead use:
    "filetype plugin on

- And then to update, call one of these:

.. code-block:: vim

    :PluginInstall!
    :PluginUpdate

- Or, if you're like the author, you could use a multi-repo Git tool,
  such as |myrepos|_ (along with the author's library, |ohmyrepos|_).

  - With |myrepos|_, you could update all your Git repos with
    the following command:

.. code-block::

    mr -d / pull

- Alternatively, if you use |ohmyrepos|_, you could pull
  just Vim plugin changes with something like this:

.. code-block::

    MR_INCLUDE=vim-plugins mr -d / pull

- After you identify your vim-plugins using the 'skip' action, e.g.:

.. code-block::

    # Put this in ~/.mrconfig, or something loaded by it.
    [DEFAULT]
    skip = mr_exclusive "vim-plugins"

    [pack/embrace-vim/start/vim-webopen]
    lib = remote_set origin https://github.com/embrace-vim/vim-webopen.git

    [DEFAULT]
    skip = false

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

