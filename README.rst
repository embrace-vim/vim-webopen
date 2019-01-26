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

Installation
============

Standard Pathogen installation:

.. code-block:: bash

   cd ~/.vim/bundle/
   git clone https://github.com/landonb/dubs_web_hatch.git

Or, Standard submodule installation:

.. code-block:: bash

   cd ~/.vim/bundle/
   git submodule add https://github.com/landonb/dubs_web_hatch.git

Online help:

.. code-block:: vim

   :Helptags
   :help dubs-web-hatch

