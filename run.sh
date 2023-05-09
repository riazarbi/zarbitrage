#!/bin/bash
echo "Getting yahoo data..."
Rscript scripts/yahoo-usdzar.R

echo "Getting luno data..."
Rscript scripts/luno-ethzar.R

echo "Getting kraken data..."
Rscript scripts/kraken-ethusd.R

echo "Computing estimated return and saving html report..."
Rscript scripts/compute_and_render.R