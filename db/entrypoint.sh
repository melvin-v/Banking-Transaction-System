#!/bin/bash
set -e

SQLCMD="/opt/mssql-tools18/bin/sqlcmd -S mssql -U sa -P $MSSQL_SA_PASSWORD -C"

echo "Creando base de datos si no existe..."
$SQLCMD -Q "IF DB_ID('Banca') IS NULL CREATE DATABASE Banca;"

echo "Aplicando schema..."
$SQLCMD -d Banca -i /db/schema.sql

echo "Init completado."