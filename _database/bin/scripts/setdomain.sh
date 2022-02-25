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

if [ ! -d ./_database/temp ]; then
  mkdir -p ./_database/temp
fi

source ./_database/bin/env/$envname.sh

echo ">>> SETTING $envdomain AS DOMAIN FOR $envhost"
echo ""
echo "update ps_shop_url set domain='$envdomain',domain_ssl='$envdomain';" >./_database/temp/setdomain.sql
mysql --host=$envhost --user=$envuser --password=$envpwd --database=$dbname <./_database/temp/setdomain.sql
rm ./_database/temp/setdomain.sql
echo ">>> DONE"
echo ""
