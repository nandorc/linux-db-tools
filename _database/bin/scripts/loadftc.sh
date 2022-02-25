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
targetenvhost=$envhost
targetenvuser=$envuser
targetenvpwd=$envpwd
targetdbname=$dbname
targetgtid=$gtid

echo ">>> LOADING FTC FILES AT $targetenvhost"
echo ""

if [ -f ./_database/bin/env/dev.sh ]; then
  echo ">>> NOTICE: Loading FTC files from DEV"
  echo ""
  envname=dev
else
  if [ -f ./_database/bin/env/qa.sh ]; then
    echo ">>> NOTICE: Loading FTC files from QA"
    echo ""
    envname=qa
  else
    if [ -f ./_database/bin/env/pdn.sh ]; then
      echo ">>> NOTICE: Loading FTC files from PDN"
      echo ""
      envname=pdn
    else
      echo ">>> ERROR: Can't reach any origin to load FTC files."
      echo ""
      exit 1
    fi
  fi
fi

source ./_database/bin/env/$envname.sh
originenvhost=$envhost
originenvuser=$envuser
originenvpwd=$envpwd
origindbname=$dbname
origingtid=$gtid

if [ ! -d ./_database/temp/ftc ]; then
  mkdir -p ./_database/temp/ftc
fi

while IFS= read -r line; do
  table=${line//[$'\t\r\n ']/}
  echo "loading $table"
  if [ "$hasgtid" = true ]; then
    mysqldump --host=$originenvhost --user=$originenvuser --password=$originenvpwd --result-file="./_database/temp/ftc/$table.sql" --compact --complete-insert --no-create-info --set-gtid-purged=OFF --skip-comments --skip-add-locks --skip-lock-tables $origindbname $table | sed -e "s/INSERT/DELETE FROM \`$table\`; INSERT/"
  else
    mysqldump --host=$originenvhost --user=$originenvuser --password=$originenvpwd --result-file="./_database/temp/ftc/$table.sql" --compact --complete-insert --no-create-info --skip-comments --skip-add-locks --skip-lock-tables $origindbname $table
  fi
  sed -i -e "s/INSERT/DELETE FROM \`$table\`; INSERT/" ./_database/temp/ftc/$table.sql
  mysql --host=$targetenvhost --user=$targetenvuser --password=$targetenvpwd --database=$targetdbname <./_database/temp/ftc/$table.sql
  rm ./_database/temp/ftc/$table.sql
done <./_database/bin/data/ftctables.text
echo ""

echo ">>> DONE"
echo ""
