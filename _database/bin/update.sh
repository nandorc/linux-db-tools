#!/bin/bash
# -*- ENCODING: UTF-8 -*-

while [ -n "$1" ]; do
  case "$1" in
  -env)
    envname="$2"
    shift
    ;;
  -owner)
    ownername="$2"
    shift
    ;;
  -gtid)
    hasgtid=true
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
if [ -z $ownername ]; then
  echo "-owner must be specified with owner's name"
  exit 1
fi

if [ -d ./_database ]; then
  if [ "$hasgtid" = true ]; then
    ./_database/bin/scripts/dumpstruct.sh -gtid -env $envname
    ./_database/bin/scripts/dumpconfig.sh -gtid -env $envname
  else
    ./_database/bin/scripts/dumpstruct.sh -env $envname
    ./_database/bin/scripts/dumpconfig.sh -env $envname
  fi
  ./_database/bin/scripts/setpermissions.sh -owner $ownername -dir ./_database
else
  echo ">>> ERROR: Script must be executed on from root and _database folder must exists"
  echo ""
  exit 1
fi
