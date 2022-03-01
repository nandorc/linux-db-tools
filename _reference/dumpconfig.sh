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

basepath="_database/config"

if [ ! -d ./$basepath ]; then
  mkdir -p ./$basepath
fi

echo ">>> FETCHING CONFIG FILES FROM $envhost"
echo ""
echo "clean old files"
rm -rf ./$basepath/*
echo ""
while IFS= read -r line; do
  table=${line//[$'\t\r\n ']/}
  echo "fetch $table config"
  if [ "$hasgtid" = true ]; then
    mysqldump --host=$envhost --user=$envuser --password=$envpwd --result-file="./$basepath/$table.sql" --compact --complete-insert --no-create-info --set-gtid-purged=OFF --skip-comments --skip-add-locks --skip-lock-tables $dbname $table
  else
    mysqldump --host=$envhost --user=$envuser --password=$envpwd --result-file="./$basepath/$table.sql" --compact --complete-insert --no-create-info --skip-comments --skip-add-locks --skip-lock-tables $dbname $table
  fi
  sed -i -e "s/),(/),\n  (/g" ./$basepath/$table.sql
  sed -i -e "s/VALUES /VALUES\n  /" ./$basepath/$table.sql
  sed -i -e "s/INSERT/DELETE FROM \`$table\`;\nINSERT/" ./$basepath/$table.sql
done <./_database/bin/data/cfgtables.text
table=ps_configuration
echo "fetch $table config"
if [ "$hasgtid" = true ]; then
  mysqldump --host=$envhost --user=$envuser --password=$envpwd --result-file="./$basepath/$table.sql" --where="name<>'PS_SHOP_DOMAIN' and name<>'PS_SHOP_DOMAIN_SSL' and name<>'shortcode_url_add' and name<>'PS_SSL_ENABLED' and name<>'PS_SSL_ENABLED_EVERYWHERE' and name<>'PS_SHOP_EMAIL' and name<>'WK_MP_SUPERADMIN_EMAIL' and name<>'PS_MAIL_USER' and name<>'PS_MAIL_PASSWD'" --replace --compact --complete-insert --no-create-info --set-gtid-purged=OFF --skip-comments --skip-add-locks --skip-lock-tables $dbname $table
else
  mysqldump --host=$envhost --user=$envuser --password=$envpwd --result-file="./$basepath/$table.sql" --where="name<>'PS_SHOP_DOMAIN' and name<>'PS_SHOP_DOMAIN_SSL' and name<>'shortcode_url_add' and name<>'PS_SSL_ENABLED' and name<>'PS_SSL_ENABLED_EVERYWHERE' and name<>'PS_SHOP_EMAIL' and name<>'WK_MP_SUPERADMIN_EMAIL' and name<>'PS_MAIL_USER' and name<>'PS_MAIL_PASSWD'" --replace --compact --complete-insert --no-create-info --skip-comments --skip-add-locks --skip-lock-tables $dbname $table
fi
sed -i -e "s/),(/),\n  (/g" ./$basepath/$table.sql
sed -i -e "s/VALUES /VALUES\n  /" ./$basepath/$table.sql
echo ""
echo ">>> DONE"
echo ""
