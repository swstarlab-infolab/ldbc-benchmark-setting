#!/bin/bash

LOAD_DATA_DIR=`pwd`/csv_data

rm load_csv.sql
cp load_csv.sql.base load_csv.sql

sed -i "s@data_dir@${LOAD_DATA_DIR}@g" load_csv.sql

psql -U postgres -d ldbcsnb -f load_csv.sql

echo 'DONE'