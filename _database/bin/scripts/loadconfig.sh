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

echo ">>> LOADING CONFIG FILES TO $envhost"
echo ""
for table in $(ls ./_database/config); do
  echo "loading $table"
  mysql --host=$envhost --user=$envuser --password=$envpwd --database=$dbname <./_database/config/$table
done
echo ""
echo ">>> DONE"
echo ""
