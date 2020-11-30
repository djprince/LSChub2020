#!/bin/bash

mkdir 1012_plotData/

#PCAs
cp 1007_pca/*annot 1007_pca/*covar 1012_plotData/

#admix
cp 1008_admix/*qopt 1008_admix/*bamlist 1012_plotData/

#tree
cp 1011_consensedTree/1k*outtree 1012_plotData/


Rscript 1000_scripts/plot.R 1012_plotData/
