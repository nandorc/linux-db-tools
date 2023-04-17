# DB-Tools for Linux

**Current version:** 1.2.1

This repository contains a tool for bash to help inpection of databases.

## Tools

`bin/dumper`

> Generates structure and data information of the tables of a database.

`bin/loader`

> Loads structure and data information of the tables of a database.

## IMPORTANT NOTE!

Make sure sql_modes at mysql server doesn't includes NO_ZERO_IN_DATE or NO_ZERO_DATE because it may cause an 'Invalid default value' error while loading tables structure.

You could set sql_modes globally at `/etc/mysql/mysql.cnf`.
