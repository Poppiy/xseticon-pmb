#!/bin/bash
# -*- coding: utf-8, tab-width: 2 -*-


function rebuild__cli_main () {
  export LANG{,UAGE}=en_US.UTF-8  # make error messages search engine-friendly
  local REPOPATH="$(readlink -m -- "$BASH_SOURCE"/../..)"
  cd -- "$REPOPATH"/src || return $?
  local TASK="${1:-and_show}"; shift
  rebuild__"$TASK" "$@" || return $?
}


function rebuild__core () {
  rebuild__maybe_install_libraries || return $?
  vdo make clean || return $?
  vdo make || return $?
}


function rebuild__and_show () {
  rebuild__core || return $?
  cd .. || return $?
  echo 'These are your freshly baked new executables:'
  local LS=(
    ls
    --format=long
    --time-style=long-iso
    --sort=time
    --color=always
    --
    bin/*
    )
  "${LS[@]}" || return $?
  echo
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


function rebuild__maybe_install_libraries () {
  local NEED=(
    libgd-dev
    )
  local MISS=()
  local PKG=
  for PKG in "${NEED[@]}"; do
    dpkg --list "$PKG" &>/dev/null || MISS+=( "$PKG" )
  done
  [ "${#MISS[@]}" == 0 ] || vdo sudo apt install "${MISS[@]}" || return $?
}









[ "$1" == --lib ] && return 0; rebuild__cli_main "$@"; exit $?
