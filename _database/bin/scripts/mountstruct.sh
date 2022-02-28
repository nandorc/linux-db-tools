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

source ./_database/bin/env/$envname.sh

echo ">>> MOUNTING DB STRUCT FROM $dbengine STRUCT FOLDER AT $envhost"
echo ""
if [ ! -d ./_database/struct/$dbengine ]; then
  if [ -d ./_database/struct/mariadb ]; then
    echo ">>> NOTICE: $dbengine struct folder not found, using mariadb struct folder instead"
    echo ""
    dbengine=mariadb
  else
    if [ -d ./_database/struct/mysql ]; then
      echo ">>> NOTICE: $dbengine struct folder not found, using mysql struct folder instead"
      echo ""
      dbengine=mysql
    else
      echo ">>> ERROR: $dbengine struct folder not found, no struct folder found"
      echo ""
      exit 1
    fi
  fi
fi
for table in $(ls ./_database/struct/$dbengine); do
  echo "mounting $table"
  mysql --host=$envhost --user=$envuser --password=$envpwd --database=$dbname <./_database/struct/$dbengine/$table
done
echo ""
echo ">>> DONE"
echo ""
