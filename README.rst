############################
Dubs Vim |em_dash| Web Hatch
############################

.. |em_dash| unicode:: 0x2014 .. em dash

Simple URL opener with search and word definition options.

At its core, opens a location in the default browser.

Can also search the web or try to define something.

Usage
=====

==============    =========================================================================
Command           Description
--------------    -------------------------------------------------------------------------

``gW``            Akin to Vim's builtin ``gf`` command, but for URLs (think: Go Web).
                  Opens a new browser window with the location of the URL under the cursor.
--------------    -------------------------------------------------------------------------
``g!``            Like ``gW``, but opens location in an incognito (aka private) browser window.
--------------    -------------------------------------------------------------------------
``<Leader>W``     Opens a new browser window and searches (Google) for the word under the cursor
                  (normal or insert mode), or for the selected text (visual mode).
--------------    -------------------------------------------------------------------------
``<Leader>D``     Opens a new browser window and loads the definition of the word under the cursor
                  (normal or insert mode), or for the selected text (visual mode).
==============    =========================================================================

The ``gW`` and ``g!`` commands work from normal mode, and the
leader commands from normal and insert modes, and on selections.

Configure
=========

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

Please feel free to open a pull request to add support for additional OSes.

Tab or Window
-------------

By default, each command opens a new browser tab in new window.

- To instead prefer opening a new tab in an existing window,
  set the following global variable to nonzero, e.g.,::

    g:vim_web_hatch_use_tab = 1

User Profile
------------

By default, when Chrome is opened, the default user profile is used.

- To instead open a window using the most recently used profile,
  set the following global variable to nonzero, e.g.,::

    g:vim_web_hatch_mru_profile = 1

Supported Browsers
------------------

This plugin works with the following browsers:

- On Debian: Google Chrome, Chromium, and Mozilla Firefox.

- On macOS: Google Chrome, Mozilla Firefox, and Apple Safari.

Note that Safari does not accept command line arguments, so it does not
respect tab vs. window, nor can it open a location in incognito mode.

Please feel free to open a pull request to add support for additional browsers.

Install
=======

Installation is easy using the packages feature (see ``:help packages``).

To install the package so that it will automatically load on Vim startup,
use a ``start`` directory, e.g.,

.. code-block:: bash

    mkdir -p ~/.vim/pack/landonb/start
    cd ~/.vim/pack/landonb/start

If you want to test the package first, make it optional instead
(see ``:help pack-add``):

.. code-block:: bash

    mkdir -p ~/.vim/pack/landonb/opt
    cd ~/.vim/pack/landonb/opt

Clone the project to the desired path:

.. code-block:: bash

    git clone https://github.com/landonb/dubs_web_hatch.git

If you installed to the optional path, tell Vim to load the package:

.. code-block:: vim

   :packadd! dubs_web_hatch

Just once, tell Vim to build the online help:

.. code-block:: vim

   :Helptags

Then whenever you want to reference the help from Vim, run:

.. code-block:: vim

   :help dubs-web-hatch

