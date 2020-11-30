#!/bin/bash -l
#SBATCH -o slurm_outs/0008_CalcAdmix-%j.out
#SBATCH -t 48:00:00 
#SBATCH --mail-type=end
#SBATCH --mail-user=djprince@ucdavis.edu

sh 1000_scripts/slurm-catch.sh 0005_S
sh 1000_scripts/slurm-catch.sh ss1_

mkdir 1008_admix/
ls 1004_alignments/*ss100k*bam > 1008_admix/all_ss100k.bamlist
ls 1004_alignments/*ss100k*bam | sed 's/_ss100k//' > 1008_admix/all_ge100k.bamlist
ls 1004_alignments/*ss100k*bam | grep -v [12345]_....._sorted | sed 's/_ss100k//' > 1008_admix/G678_ge100k.bamlist
ls 1004_alignments/*ss100k*bam | grep -v [12345]_....._sorted | sed 's/_ss100k//' > 1008_admix/G678_ss100k.bamlist

ls 1004_alignments/*ss200k*bam > 1008_admix/all_ss200k.bamlist
ls 1004_alignments/*ss200k*bam | sed 's/_ss200k//' > 1008_admix/all_ge200k.bamlist
ls 1004_alignments/*ss200k*bam | grep -v [12345]_....._sorted | sed 's/_ss200k//' > 1008_admix/G678_ge200k.bamlist
ls 1004_alignments/*ss200k*bam | grep -v [12345]_....._sorted | sed 's/_ss200k//' > 1008_admix/G678_ss200k.bamlist

ls 1008_admix/*bamlist | sed 's/.bamlist//' > list
input="list"
wc=$(wc -l $input | awk '{print $1}')
x=1
while [ $x -le $wc ]
do

        string="sed -n ${x}p $input"
        str=$($string)

        var=$(echo $str | awk -F"\t" '{print $1,$2,$3}')
        set -- $var
        c1=$1
        c2=$2
        c3=$3
echo "#!/bin/bash
#SBATCH -t 48:00:00
#SBATCH -o slurm_outs/0008_admix-%j.out
angsd -GL 1 -out ${c1} -doGlf 2 -doMajorMinor 1 -SNP_pval 1e-6 -doMaf 1  -bam ${c1}.bamlist

NGSadmix -likes ${c1}.beagle.gz -K 8 -o ${c1}_k8 -minMaf 0.05
NGSadmix -likes ${c1}.beagle.gz -K 7 -o ${c1}_k7 -minMaf 0.05
NGSadmix -likes ${c1}.beagle.gz -K 6 -o ${c1}_k6 -minMaf 0.05
NGSadmix -likes ${c1}.beagle.gz -K 5 -o ${c1}_k5 -minMaf 0.05
NGSadmix -likes ${c1}.beagle.gz -K 4 -o ${c1}_k4 -minMaf 0.05
NGSadmix -likes ${c1}.beagle.gz -K 3 -o ${c1}_k3 -minMaf 0.05
NGSadmix -likes ${c1}.beagle.gz -K 2 -o ${c1}_k2 -minMaf 0.05
" > admix${x}.sh

sbatch admix${x}.sh
sleep 3s
rm admix${x}.sh
        x=$(( $x + 1 ))

done
rm list
