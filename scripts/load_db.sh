#!/bin/dash

db=magento_ww

echo 'Dropping DB'
echo "drop database ${db};" | mysql
echo 'Creating DB'
echo "create database ${db};" | mysql
echo 'Loading data'
mysql ${db} < $1
