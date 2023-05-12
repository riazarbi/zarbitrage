#!/bin/bash
echo "Extracting data..."
Rscript scripts/extract.R


echo "Computing estimated return and saving html report..."
Rscript scripts/compute_and_render.R