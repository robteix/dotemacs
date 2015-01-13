#!/bin/sh

emacs --batch --eval '(byte-recompile-directory "~/.emacs.d")'
rm -f init.elc
