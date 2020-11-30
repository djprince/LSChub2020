#!/bin/bash -l
#SBATCH -t 48:00:00
#SBATCH -o slurm_outs/0004_Align-%j.out
#SBATCH --mail-type=end
#SBATCH --mail-user=djprince@ucdavis.edu

sh 1000_scripts/slurm-catch.sh 0003_S

bwa index 1003_stacks/catalog.fa.gz
mkdir 1004_alignments/

ls 1002_samples/*1.fq | sed 's/.1.fq//' | sed 's:1002_samples/::' > 1002_samples/samplelist

wc=$(wc -l 1002_samples/samplelist | awk '{print $1}')
x=1
while [ $x -le $wc ] 
do
	string="sed -n ${x}p 1002_samples/samplelist" 
	str=$($string)

	var=$(echo $str | awk -F"\t" '{print $1,$2,$3}')   
	set -- $var
	c1=$1
	c2=$2
	c3=$3

echo "#!/bin/bash
#SBATCH -o slurm_outs/0004_aln_${c1}-%j.out
bwa mem 1003_stacks/catalog.fa.gz 1002_samples/${c1}.1.fq 1002_samples/${c1}.2.fq > 1004_alignments/${c1}.sam
samtools view -bS 1004_alignments/${c1}.sam > 1004_alignments/${c1}.bam
samtools sort  1004_alignments/${c1}.bam > 1004_alignments/${c1}_sorted.bam
samtools view -b -f 0x2 1004_alignments/${c1}_sorted.bam > 1004_alignments/${c1}_sorted_proper.bam
samtools rmdup 1004_alignments/${c1}_sorted_proper.bam 1004_alignments/${c1}_sorted_proper_rmdup.bam
samtools index 1004_alignments/${c1}_sorted_proper_rmdup.bam 1004_alignments/${c1}_sorted_proper_rmdup.bam.bai
reads=\$(samtools view -c 1004_alignments/${c1}_sorted.bam)
ppalign=\$(samtools view -c 1004_alignments/${c1}_sorted_proper.bam)
rmdup=\$(samtools view -c 1004_alignments/${c1}_sorted_proper_rmdup.bam)
echo \"\${reads},\${ppalign},\${rmdup}\" > 1004_alignments/${c1}.stats

#subsample
count=\$(samtools view -c 1004_alignments/${c1}_sorted_proper_rmdup.bam)

        if [ 100000 -le \$count ]
        then
                frac=\$(bc -l <<< 100000/\$count)
        samtools view -bs \$frac 1004_alignments/${c1}_sorted_proper_rmdup.bam > 1004_alignments/${c1}_sorted_proper_rmdup_ss100k.bam
                samtools index 1004_alignments/${c1}_sorted_proper_rmdup_ss100k.bam 1004_alignments/${c1}_sorted_proper_rmdup_ss100k.bam.bai
        fi

        if [ 200000 -le \$count ]
        then
                frac=\$(bc -l <<< 200000/\$count)
        samtools view -bs \$frac 1004_alignments/${c1}_sorted_proper_rmdup.bam > 1004_alignments/${c1}_sorted_proper_rmdup_ss200k.bam
                samtools index 1004_alignments/${c1}_sorted_proper_rmdup_ss200k.bam 1004_alignments/${c1}_sorted_proper_rmdup_ss200k.bam.bai
        fi

ss100k_count=\$(samtools view -c 1004_alignments/${c1}_sorted_proper_rmdup_ss100k.bam)
ss200k_count=\$(samtools view -c 1004_alignments/${c1}_sorted_proper_rmdup_ss200k.bam)

echo \"\${count},\${ss100k_count},\${ss200k_count}\" > 1004_alignments/${c1}_ss.counts" > aln_${x}.sh
sbatch -p high -t 24:00:00 aln_${x}.sh
rm aln_${x}.sh
sleep 15s
	x=$(( $x + 1 ))
done

