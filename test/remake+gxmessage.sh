#!/bin/bash
# -*- coding: utf-8, tab-width: 2 -*-


function remake () {
  export LANG{,UAGE}=en_US.UTF-8  # make error messages search engine-friendly
  local REPOPATH="$(readlink -m -- "$BASH_SOURCE"/../..)"
  cd -- "$REPOPATH"/src || return $?

  source -- rebuild.sh --lib || return $?
  rebuild__core || return $?

  local XM='gxmessage'
  local WIN_NAME='xseticon-target'
  local WIN_ID="$(find_target_window)"
  if [ -z "$WIN_ID" ]; then
    "$XM" -name "$WIN_NAME" -ontop 'Hello World.' &
    sleep 2s
    WIN_ID="$(find_target_window)"
  fi
  [ -n "$WIN_ID" ] || return 3$(echo "E: unable to find target window." >&2)

  local XSI=(
    vdo
    ./xseticon-pmb.elf
    --verbose
    "$WIN_ID"
    png
    )
  local ICONS_PATH='/usr/share/icons/gnome/48x48/apps'
  local ICON_FILES=(
    libreoffice-{base,calc,draw}.png
    )
  local ICON=
  for ICON in "${ICON_FILES[@]}"; do
    "${XSI[@]}" "$ICONS_PATH/$ICON" || return $?
    sleep 1s
  done
}


function find_target_window () {
  wmctrl -xl | sed -nrf <(echo '
    s~\s+~ ~g
    s~^(0x\S+) \S+ '"$WIN_NAME"'\.'"${XM^}"'\s.*$~\1~p
    ')
}










remake "$@"; exit $?
