#!/bin/bash
# -*- ENCODING: UTF-8 -*-

while [ -n "$1" ]; do
  case "$1" in
  -env)
    envname="$2"
    shift
    ;;
  -domain)
    envdomain="$2"
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
if [ -z $envdomain ]; then
  echo "-domain must be specified"
  exit 1
fi
if [ -z $ownername ]; then
  echo "-owner must be specified with owner's name"
  exit 1
fi

if [ -d ./_database ]; then
  ./_database/bin/scripts/mountstruct.sh -env $envname
  if [ $? = 0 ]; then
    if [ "$hasgtid" = true ]; then
      ./_database/bin/scripts/loadftc.sh -gtid -env $envname
    else
      ./_database/bin/scripts/loadftc.sh -env $envname
    fi
  fi
  if [ $? = 0 ]; then
    ./_database/bin/scripts/setdomain.sh -env $envname -domain $envdomain
  fi
  if [ $? = 0 ]; then
    ./_database/bin/scripts/loadconfig.sh -env $envname
  fi
  if [ $? = 0 ]; then
    ./_database/bin/scripts/setpermissions.sh -owner $ownername -dir .
  fi
else
  echo ">>> ERROR: Script must be executed on from root and _database folder must exists"
  echo ""
  exit 1
fi
