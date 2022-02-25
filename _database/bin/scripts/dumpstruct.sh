#!/bin/bash
# -*- ENCODING: UTF-8 -*-

while [ -n "$1" ]; do
  case "$1" in
  -env)
    envname="$2"
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
    exit
    ;;
  esac
  shift
done

if [ -z $envname ]; then
  echo "-env must be specified"
  exit
fi

source ./_database/bin/env/$envname.sh

basepath="_database/struct"

if [ ! -d ./$basepath ]; then
  mkdir -p ./$basepath
fi

echo ">>> FETCHING STRUCT FILES FROM $envhost"
echo ""
if [ -d ./$basepath/$dbengine ]; then
  echo "clean old files"
  rm -rf ./$basepath/$dbengine/*
else
  echo "create $dbengine folder"
  mkdir ./$basepath/$dbengine
fi
echo ""
while IFS= read -r line; do
  table=${line//[$'\t\r\n ']/}
  echo "fetch $table struct"
  if [ "$hasgtid" = true ]; then
    mysqldump --host=$envhost --user=$envuser --password=$envpwd --result-file="./$basepath/$dbengine/$table.sql" --compact --no-data --add-drop-table --set-gtid-purged=OFF --skip-comments --skip-add-locks --skip-lock-tables $dbname $table
  else
    mysqldump --host=$envhost --user=$envuser --password=$envpwd --result-file="./$basepath/$dbengine/$table.sql" --compact --no-data --add-drop-table --skip-comments --skip-add-locks --skip-lock-tables $dbname $table
  fi
  sed -i -e 's/ AUTO_INCREMENT=[0-9]\+//' ./$basepath/$dbengine/$table.sql
done <./_database/bin/data/alltables.text
echo ""
echo ">>> DONE"
echo ""
