#!/bin/sed -nurf
# -*- coding: UTF-8, tab-width: 2 -*-

/^Usage$/!b;n
/^\-+$/!b;n

: skip_blank
/^$/{n;b skip_blank}

/^`{3}text$/!b;n

: collect
/\n`{3}$/!{N; b collect}

s~\n```~~
s~[\\"']~\\&~g
s~\n~\\n~g

s~^(Usage: )(\S+) ~#define README_PROGNAME "\2"\
  #define README_USAGE "\1%s %s", README_PROGNAME, "~
s~$~\\n"~
s~^~\
  // This file is generated from README.md.\
  // Any edits are futile, as they will probably be lost.\
  \n~

s~\n +~\n~g
s~^\n~~

p
