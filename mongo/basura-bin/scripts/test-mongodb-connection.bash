#!/bin/bash

DB_USER=$1
DB_PASSWORD=$2
DB_HOST_AND_PORT=$3
DB_NAME=$4

mongo -u ${DB_USER} -p ${DB_PASSWORD} ${DB_HOST_AND_PORT}/${DB_NAME}
