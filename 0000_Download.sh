#!/bin/bash

mkdir slurm_outs/
mkdir 1001_sequence/
mkdir 1001_sequence/plates/
cd 1001_sequence/plates/
wget http://agri.cse.ucdavis.edu/~djprince/LSCHUB/seq/CAACATAT_R1.fastq.gz
wget http://agri.cse.ucdavis.edu/~djprince/LSCHUB/seq/CAACATAT_R2.fastq.gz
wget http://agri.cse.ucdavis.edu/~djprince/LSCHUB/seq/GTGCATAT_R1.fastq.gz
wget http://agri.cse.ucdavis.edu/~djprince/LSCHUB/seq/GTGCATAT_R2.fastq.gz
wget http://agri.cse.ucdavis.edu/~djprince/LSCHUB/seq/TTTGATAT_R1.fastq.gz
wget http://agri.cse.ucdavis.edu/~djprince/LSCHUB/seq/TTTGATAT_R2.fastq.gz

gunzip CAACATAT_R1.fastq.gz
gunzip CAACATAT_R2.fastq.gz
gunzip GTGCATAT_R1.fastq.gz
gunzip GTGCATAT_R2.fastq.gz
gunzip TTTGATAT_R1.fastq.gz
gunzip TTTGATAT_R2.fastq.gz
