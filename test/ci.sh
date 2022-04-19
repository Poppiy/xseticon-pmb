#!/bin/bash
# -*- coding: utf-8, tab-width: 2 -*-


function ci_main () {
  export LANG{,UAGE}=en_US.UTF-8  # make error messages search engine-friendly
  local SELFPATH="$(readlink -m -- "$BASH_SOURCE"/..)"
  cd -- "$SELFPATH"/.. || return $?

  local APT_PKG=(
    libgd-dev
    libxmu-dev
    )
  vdo sudo apt install "${APT_PKG[@]}" || return $?
  vdo make clean || return $?
  vdo make || return $?
  vdo which xseticon
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



ci_main "$@"; exit $?
