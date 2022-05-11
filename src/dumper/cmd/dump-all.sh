#!/bin/bash

# Set variables
output_folder=$1 && dbhost=$2 && dbuser=$3 && dbpwd=$4 && dbname=$5 && has_gtid=$6

# Check variables
if [ -z "$output_folder" ] || [ -z "$dbhost" ] || [ -z "$dbuser" ] || [ -z "$dbname" ]; then
    echo -e "\e[31mNo valid data received for database connection\e[0m" && exit 1
fi

# Get tables names
echo -e "\n\e[34mGetting tables names at $dbname...\c"
tables_list=$(mysql --host="$dbhost" --user="$dbuser" --password="$dbpwd" --database="$dbname" --execute="show tables;" --skip-column-names 2>&1 | grep -v "Warning")
tables_list_array=(${tables_list// / })
echo -e "OK\e[0m"

# Dump tables structure
echo -e "\n\e[34mDumping structure of tables at $dbname\e[0m"
for i in "${tables_list_array[@]}"; do
    echo -e " * Dumping $dbname.$i\c"
    if [ $has_gtid -eq 1 ]; then
        echo -e " using gtid supression...\c"
        mysqldump --host="$dbhost" --user="$dbuser" --password="$dbpwd" --result-file="$output_folder/struct/$i.sql" --compact --no-data --add-drop-table --set-gtid-purged=OFF --skip-comments --skip-add-locks --skip-lock-tables "$dbname" "$i" 2>&1 | grep -v "Warning" | grep -v "Error"
    else
        echo -e "...\c"
        mysqldump --host="$dbhost" --user="$dbuser" --password="$dbpwd" --result-file="$output_folder/struct/$i.sql" --compact --no-data --add-drop-table --skip-comments --skip-add-locks --skip-lock-tables "$dbname" "$i" 2>&1 | grep -v "Warning" | grep -v "Error"
    fi
    sed -i -e 's/ AUTO_INCREMENT=[0-9]\+//' "$output_folder"/struct/"$i".sql
    sed -i -e '/^\/\*/d' "$output_folder"/struct/"$i".sql
    echo -e "DONE"
done

# Dump tables data
echo -e "\n\e[34mDumping data of tables at $dbname\e[0m"
for i in "${tables_list_array[@]}"; do
    echo -e " * Dumping $dbname.$i\c"
    if [ $has_gtid -eq 1 ]; then
        echo -e " using gtid supression...\c"
        mysqldump --host="$dbhost" --user="$dbuser" --password="$dbpwd" --result-file="$output_folder/data/$i.sql" --compact --complete-insert --no-create-info --set-gtid-purged=OFF --skip-comments --skip-add-locks --skip-lock-tables "$dbname" "$i" 2>&1 | grep -v "Warning" | grep -v "Error"
    else
        echo -e "...\c"
        mysqldump --host="$dbhost" --user="$dbuser" --password="$dbpwd" --result-file="$output_folder/data/$i.sql" --compact --complete-insert --no-create-info --skip-comments --skip-add-locks --skip-lock-tables "$dbname" "$i" 2>&1 | grep -v "Warning" | grep -v "Error"
    fi
    sed -i -e "s/),(/),\n  (/g" "$output_folder"/data/"$i".sql
    sed -i -e "s/VALUES /VALUES\n  /" "$output_folder"/data/"$i".sql
    echo -e "DONE"
done

# End line
echo -e ""
