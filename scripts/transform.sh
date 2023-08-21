#!/bin/bash
rm data/warehouse.duckdb
dbt deps
dbt build