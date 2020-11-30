#!/bin/bash -l
#SBATCH -o slurm_outs/0005_CalcHWE-%j.out
#SBATCH -t 4-00:00:00
#SBATCH -p high
#SBATCH --mail-type=end
#SBATCH --mail-user=djprince@ucdavis.edu

mkdir 1005_HWE/
gunzip -c 1003_stacks/catalog.fa.gz > 1005_HWE/catalog.fa

cat chub.metadata | awk '{print $1"_"$5}' | sort | uniq > 1005_HWE/pop.list

input="1005_HWE/pop.list"
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
#SBATCH -o slurm_outs/0005_hwe-%j.out
#SBATCH -p high
#SBATCH --mem=4G

ls 1004_alignments/${c1}*ss100k*.bam | sed 's/_ss100k//' > 1005_HWE/${c1}.bamlist

angsd -b 1005_HWE/${c1}.bamlist -out 1005_HWE/${c1} -doHWE 1 -gl 1 -domajorminor 1 -doMaf 1 -SNP_pval 1e-6 -minMaf 0.05
gunzip 1005_HWE/${c1}.hwe.gz
cat 1005_HWE/${c1}.hwe | cut -f9 | sed 1d | awk '{total+=\$1; count+=1} END {print total/count}' > 1005_HWE/${c1}.hwe.avg
" > hwe_${x}.sh
sbatch hwe_${x}.sh
sleep 1s
rm hwe_${x}.sh

        x=$(( $x + 1 ))

done

