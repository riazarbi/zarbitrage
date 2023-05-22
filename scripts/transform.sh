#!/bin/bash
rm data/warehouse.duckdb
duckdb data/warehouse.duckdb 
dbt build