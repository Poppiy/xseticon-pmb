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
  vteelog tmp.make.log make || return $?
}


function vteelog () {
  local LOG_FN="$1"; shift
  local RV=
  vdo "$@" >& >(tee -- "$LOG_FN")
  RV=$?
  sleep 0.2s # wait for the tee subprocess to finish writing its output.
  [ "$RV" == 0 ] || echo "E: '$1' failed. Errors were logged to $LOG_FN." >&2
  return "$RV"
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
  local NEED=()
  readarray -t NEED < <(
    grep -Pe '^\w' -- "$REPOPATH"/src/deps.libs.apt-pkg.txt)
  local MISS=()
  local PKG=
  for PKG in "${NEED[@]}"; do
    dpkg --list "$PKG" &>/dev/null || MISS+=( "$PKG" )
  done
  [ "${#MISS[@]}" == 0 ] || vdo sudo apt install "${MISS[@]}" || return $?
}









[ "$1" == --lib ] && return 0; rebuild__cli_main "$@"; exit $?
