#! /bin/bash

set -e

dbt docs generate
python3 scripts/fix_docs.py
mv target/index2.html docs/documentation.html