#!/bin/bash -l
#SBATCH -o slurm_outs/0007_CalcPCAs-%j.out
#SBATCH -t 48:00:00
#SBATCH --mail-type=end
#SBATCH --mail-user=djprince@ucdavis.edu

module load angsd/
mkdir 1007_pca/ 

ls $PWD/1004_alignments/*ss100k.bam > 1007_pca/all_ss100k.bamlist
ls $PWD/1004_alignments/*ss200k.bam > 1007_pca/all_ss200k.bamlist

ls $PWD/1004_alignments/*ss100k.bam | grep -v [123]_....._sorted > 1007_pca/G4-8_ss100k.bamlist
ls $PWD/1004_alignments/*ss200k.bam | grep -v [123]_....._sorted > 1007_pca/G4-8_ss200k.bamlist

ls $PWD/1004_alignments/*ss100k.bam | grep -v [12345]_....._sorted > 1007_pca/G6-8_ss100k.bamlist
ls $PWD/1004_alignments/*ss200k.bam | grep -v [12345]_....._sorted > 1007_pca/G6-8_ss200k.bamlist

ls $PWD/1004_alignments/*ss100k.bam | grep 8_....._sorted > 1007_pca/G8_ss100k.bamlist
ls $PWD/1004_alignments/*ss200k.bam | grep 8_....._sorted > 1007_pca/G8_ss200k.bamlist

ls $PWD/1004_alignments/*ss100k.bam | grep -v [12356]_....._sorted > 1007_pca/G478_ss100k.bamlist
ls 1007_pca/*bamlist | sed 's:1007_pca/::g' | sed 's:.bamlist::g' > pcalist

wc=$(wc -l pcalist | awk '{print $1}')
x=1
while [ $x -le $wc ] 
do

        string="sed -n ${x}p pcalist" 
        str=$($string)

        var=$(echo $str | awk -F"\t" '{print $1}')   
        set -- $var
        c1=$1

	nInd=$(wc -l 1007_pca/${c1}.bamlist | awk '{print $1}')
	minInd=$[$nInd/2]

	echo "#!/bin/bash -l" > ${c1}.sh
	echo "#SBATCH -o 1007_pca/0007_pca${c1}-%j.out" >> ${c1}.sh
	echo "angsd -bam 1007_pca/${c1}.bamlist -out 1007_pca/${c1} -minQ 20 -minMapQ 10 -minInd $minInd -GL 1 -doMajorMinor 1 -doMaf 2 -SNP_pval 1e-6 -minMaf 0.05 -doGeno 32 -doPost 2" >> ${c1}.sh
	echo "gunzip 1007_pca/${c1}*.gz" >> ${c1}.sh
	echo "count=\$(sed 1d 1007_pca/${c1}*mafs| wc -l | awk '{print \$1}')" >> ${c1}.sh
	echo "/home/djprince/programs/ngsTools/ngsPopGen/ngsCovar -probfile 1007_pca/${c1}.geno -outfile 1007_pca/${c1}.covar -nind $nInd -nsites \$count -call 1

 cat 1007_pca/${c1}.bamlist | sed 's:.*alignments/::' | sed 's/_sorted.*//' > 1007_pca/${c1}.samplelist
        echo \"SHAPE    COLOR   LABEL\" > ${c1}.header
        cat 1007_pca/${c1}.samplelist | cut -d\"_\" -f2 | cut -c 1-3 > ${c1}.pop
        cat 1007_pca/${c1}.samplelist | cut -d\"_\" -f2 | cut -c 4-5 > ${c1}.ind
        cat 1007_pca/${c1}.samplelist | cut -d\"_\" -f1 > ${c1}.group
        paste ${c1}.ind ${c1}.group ${c1}.pop > ${c1}.body
        rm ${c1}.ind ${c1}.group ${c1}.pop
        cat ${c1}.header ${c1}.body > 1007_pca/${c1}.annot
        rm ${c1}.header ${c1}.body	" >> ${c1}.sh
	sbatch -p bigmemh -t 48:00:00 -J djppca ${c1}.sh
	rm ${c1}.sh

 x=$(( $x + 1 ))
done
rm pcalist

