#!/bin/bash

rm data/warehouse.duckdb

duckdb data/warehouse.duckdb < scripts/transform.sql 