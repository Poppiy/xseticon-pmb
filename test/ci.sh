#!/bin/bash
# -*- coding: utf-8, tab-width: 2 -*-


function ci_main () {
  export LANG{,UAGE}=en_US.UTF-8  # make error messages search engine-friendly
  local REPOPATH="$(readlink -m -- "$BASH_SOURCE"/../..)"
  cd -- "$REPOPATH"/src || return $?

  local PROG_NAME='xseticon-pmb'
  local APT_PKG=(
    libgd-dev
    libxmu-dev
    )
  vdo sudo apt install "${APT_PKG[@]}" || return $?
  vdo make clean || return $?
  vdo make || return $?
  vdo grep_usage ./"$PROG_NAME".elf || return $?
  vdo sudo make install || return $?
  vdo which "$PROG_NAME" || return $?
  vdo grep_usage "$PROG_NAME" || return $?
}


function vdo () {
  echo
  echo "==-----== $* ==-----== start ==-----=="
  SECONDS=0
  "$@"
  local RV=$?
  echo "==-----== $* ==-----== done, $SECONDS sec, rv=$RV ==-----=="
  echo
  return "$RV"
}


function grep_usage () { "$@" |& grep -Fe 'Usage:'; }



ci_main "$@"; exit $?
