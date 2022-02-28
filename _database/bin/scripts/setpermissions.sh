#!/bin/bash
# -*- ENCODING: UTF-8 -*-

while [ -n "$1" ]; do
  case "$1" in
  -owner)
    ownername="$2"
    shift
    ;;
  -dir)
    dirpath="$2"
    shift
    ;;
  --)
    shift
    break
    ;;
  *)
    echo "No valid options provided"
    exit 1
    ;;
  esac
  shift
done

if [ -z $ownername ]; then
  echo "-owner must be specified with owner's name"
  exit 1
fi
if [ -z $dirpath ]; then
  echo "-dir must be specified with base path to apply permissions"
  exit 1
fi

function setPermission() {
  # $1 - file/folder parent path
  # $2 - file/folder path
  if [ "$2" != "$1/." -a "$2" != "$1/.." -a "$2" != "$1/*" ]; then
    if [ -d "$2" ]; then
      # echo "$2 is a directory"
      chmod -v 775 "$2"
      alterFiles "$2"
    else
      if [[ "$2" =~ ".sh" ]]; then
        # echo "$2 is a sh file"
        chmod -v 774 "$2"
      else
        # echo "$2 is a file"
        chmod -v 664 "$2"
      fi
    fi
  fi
}

function alterFiles() {
  # $1 root folder path
  for file in "$1"/*; do
    setPermission "$1" "$file"
  done
  for file in "$1"/.?*; do
    setPermission "$1" "$file"
  done
}

echo ">>> SETTING FILES AND FOLDER RIGHTS"
echo ""
chown -R -v "$ownername":"$ownername" "$dirpath"
alterFiles "$dirpath"
echo ""
echo ">>> DONE"
echo ""