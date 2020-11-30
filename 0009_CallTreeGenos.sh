#!/bin/bash
#SBATCH -o slurm_outs/0009_CallTreeGenos-%j.out
#SBATCH --mem 80G
#SBATCH -p bigmemh
#SBATCH -t 48:00:00
#SBATCH --mail-type=end
#SBATCH --mail-user=djprince@ucdavis.edu

mkdir 1009_treeGenos

ls 1004_alignments/*ss200k*bam | sed 's/_ss200k//' > 1009_treeGenos/TreeGeno.bamlist


nInd=$(wc -l 1009_treeGenos/TreeGeno.bamlist | awk '{print $1}')
minInd=$[$nInd-$nInd/10]

angsd -bam 1009_treeGenos/TreeGeno.bamlist -out 1009_treeGenos/TreeGeno -GL 1 -doMajorMinor 1 -doMaf 2 -doGeno 4 -doPost 2 -postCutoff 0.8 -SNP_pval 1e-6 -minInd $minInd -minMaf 0.0025

gunzip 1009_treeGenos/*gz

mkdir 1009_treeGenos/cons_seq
 cat 1009_treeGenos/TreeGeno.bamlist | sed 's:.*alignments/::' | sed 's:_sorted.*::' > 1009_treeGenos/TreeGeno.samplist
x=1
while [ $x -le 1000 ]
do

echo "#!/bin/bash
#SBATCH -t 48:00
#SBATCH --mem=1G
#SBATCH -p high
#SBATCH -o slurm_outs/0009_tree$x-%j.out

perl 1000_scripts/call_cons.pl 1009_treeGenos/TreeGeno.samplist 1009_treeGenos/TreeGeno.geno > 1009_treeGenos/cons_seq/TreeGeno_cons_$x.fa " > cons_$x.sh
sbatch cons_$x.sh
sleep 1s
rm cons_$x.sh


        x=$(( $x + 1 ))
done

