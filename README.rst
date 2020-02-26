############################
Dubs Vim |em_dash| Web Hatch
############################

.. |em_dash| unicode:: 0x2014 .. em dash

Simple web browser tab opener to search on or load definition of selected text.

Usage
=====

``<Leader>W`` - Opens a browser tab and searches the word under the cursor
(normal or insert mode) or the selected text (visual mode).

``<Leader>D`` - Opens a browser tab and loads the definitions of the word
under the cursor (normal or insert mode) or the selected text (visual mode).

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

