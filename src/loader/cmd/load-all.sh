#!/bin/bash

# Set variables
origin_folder=$1 && dbhost=$2 && dbuser=$3 && dbpwd=$4 && dbname=$5

# Check variables
if [ -z "$dbhost" ] || [ -z "$dbuser" ] || [ -z "$dbname" ]; then
    echo -e "\n\e[31mExecution Exception:\e[0m No valid data received for database connection\n" && exit 1
fi

# Get tables names
echo -e "\n\e[34mGetting current tables names at $dbname...\c"
tables_list=$(mysql --host="$dbhost" --user="$dbuser" --password="$dbpwd" --database="$dbname" --execute="show tables;" 2>&1)
[ $? -ne 0 ] && echo -e "\e[31mExecution Exception:\e[0m Can't connect to database\n\e[33mCheck variables for connection or mysql server status\e[0m\n" && exit 1
tables_list=$(mysql --host="$dbhost" --user="$dbuser" --password="$dbpwd" --database="$dbname" --execute="show tables;" --skip-column-names 2>&1 | grep -v "Warning")
tables_list_array=(${tables_list// / })
echo -e "OK\e[0m"

# Drop current tables
echo -e "\n\e[34mDropping tables at $dbname\e[0m"
if [ ${#tables_list_array[@]} -eq 0 ]; then
    echo -e "\e[33m * Nothing to drop\e[0m"
else
    for i in "${tables_list_array[@]}"; do
        echo -e " * Dropping $dbname.$i...\c"
        mysql --host="$dbhost" --user="$dbuser" --password="$dbpwd" --database="$dbname" --execute="drop table if exists $i;" 2>&1 | grep -v "Warning"
        echo -e "DONE"
    done
fi

# Load tables structure files
echo -e "\n\e[34mLoading structure for tables at $dbname\e[0m"
if [ ! -d "$origin_folder"/struct ]; then
    echo -e "\e[33m * Folder '$origin_folder/struct' doesn't exists\e[0m"
    echo -e "\e[33m * Nothing to load\e[0m"
else
    struct_files=$(ls "$origin_folder"/struct)
    struct_files_array=(${struct_files// / })
    if [ ${#struct_files_array[@]} -eq 0 ]; then
        echo -e "\e[33m * Nothing to load\e[0m"
    else
        for i in "${struct_files_array[@]}"; do
            echo -e " * Loading $dbname.$i structure...\c"
            mysql --init-command="SET SESSION FOREIGN_KEY_CHECKS=0;" --host="$dbhost" --user="$dbuser" --password="$dbpwd" --database="$dbname" <"$origin_folder"/struct/"$i" 2>&1 | grep -v "Warning"
            echo -e "DONE"
        done
    fi
fi

# Load tables data files
echo -e "\n\e[34mLoading data for tables at $dbname\e[0m"
if [ ! -d "$origin_folder"/data ]; then
    echo -e "\e[33m * Folder '$origin_folder/data' doesn't exists\e[0m"
    echo -e "\e[33m * Nothing to load\e[0m"
else
    data_files=$(ls "$origin_folder"/data)
    data_files_array=(${data_files// / })
    if [ ${#data_files_array[@]} -eq 0 ]; then
        echo -e "\e[33m * Nothing to load\e[0m"
    else
        for i in "${data_files_array[@]}"; do
            echo -e " * Loading $dbname.$i data...\c"
            mysql --init-command="SET SESSION FOREIGN_KEY_CHECKS=0;" --host="$dbhost" --user="$dbuser" --password="$dbpwd" --database="$dbname" <"$origin_folder"/data/"$i" 2>&1 | grep -v "Warning"
            echo -e "DONE"
        done
    fi
fi

# End line
echo -e "\n\e[34mOperation completed\e[0m\n"
