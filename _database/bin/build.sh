#!/bin/bash
# -*- ENCODING: UTF-8 -*-

while [ -n "$1" ]; do
  case "$1" in
  -env)
    envname="$2"
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

if [ -z $envname ]; then
  echo "-env must be specified"
  exit 1
fi

if [ -d ./_database ]; then
  ./_database/bin/scripts/loadconfig.sh -env $envname
else
  echo ">>> ERROR: Script must be executed on from root and _database folder must exists"
  echo ""
  exit 1
fi