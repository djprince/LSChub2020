#!/bin/bash
#SBATCH -t 2-00:00:00 
#SBATCH -o slurm_outs/0002_Rename-%j.out

mkdir 1002_samples/
input="chub.metadata"
wc=$(wc -l $input | awk '{print $1}')
x=1
while [ $x -le $wc ]
do

        string="sed -n ${x}p $input"
        str=$($string)

        var=$(echo $str | awk -F"\t" '{print $1,$2,$3,$4}')
        set -- $var
        c1=$1
        c2=$2
        c3=$3
	c4=$4

	mv 1001_sequence/${c3}AT_GG${c4}TGCAGG_RA.fastq 1002_samples/${c1}_${c2}.1.fq
	mv 1001_sequence/${c3}AT_GG${c4}TGCAGG_RB.fastq 1002_samples/${c1}_${c2}.2.fq

        x=$(( $x + 1 ))

done

wc -l 1002_samples/*1.fq | sort -nr > 1002_samples/wc.txt

