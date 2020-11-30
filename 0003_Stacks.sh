#!/bin/bash
#SBATCH -t 48:00:00
#SBATCH -c 8 
#SBATCH -p bigmemh
#SBATCH -o slurm_outs/0003_Stacks-%j.out
#SBATCH --mem=80G
#SBATCH --mail-type=end
#SBATCH --mail-user=djprince@ucdavis.edu



mkdir 1003_stacks/
module load stacks/2.53


head -n 262 1002_samples/wc.txt | awk '{print $2}' | sed 's:.1.fq:	:' | sed 's:1002_samples/::' | sed 1d | sed 's/ .*$//' > 1003_stacks/uStacks.samplelist

cut -d"_" -f2 1003_stacks/uStacks.samplelist > 1003_stacks/uStacks.samplelist2
grep -f 1003_stacks/uStacks.samplelist2 chub.metadata | awk '{print $1"_"$2"\t"$1"_"$5}' > 1003_stacks/uStacks.popmap

input="1003_stacks/uStacks.samplelist"
wc=$(wc -l $input | awk '{print $1}')
x=1
while [ $x -le $wc ]
do

        string="sed -n ${x}p $input"
        str=$($string)

        var=$(echo $str | awk -F"\t" '{print $1}')
        set -- $var
        sample=$1


        echo "#!/bin/bash
	#SBATCH -o slurm_outs 0003_ustacks -%j.out
	#SBATCH -t 48:00:00
	ustacks -f 1002_samples/${sample}.1.fq -o 1003_stacks/ -i $x --name $sample -M 4 -p 8" > ustack_${sample}.sh
	sbatch  ustack_${sample}.sh
	sleep 1s
	rm  ustack_${sample}.sh

        x=$(( $x + 1 ))

done

sleep 1m
1000_scripts/slurm-catch.sh ustack
sleep 1m

cstacks -n 6 -P 1003_stacks/ -M 1003_stacks/uStacks.popmap -p 8

sstacks -P 1003_stacks/ -M 1003_stacks/uStacks.popmap -p 8 

tsv2bam -P 1003_stacks/ -M 1003_stacks/uStacks.popmap --pe-reads-dir 1002_samples/ -t 8 

gstacks -P 1003_stacks/ -M 1003_stacks/uStacks.popmap -t 8 

populations -P 1003_stacks/ -M 1003_stacks/uStacks.popmap -r 0.8 --structure --phylip --vcf --fstats --treemix -t 8
