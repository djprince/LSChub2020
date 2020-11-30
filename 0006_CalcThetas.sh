#!/bin/bash -l
#SBATCH -o slurm_outs/0006_CalcThetas-%j.out
#SBATCH -t 4-00:00:00
#SBATCH -p high
#SBATCH --mail-type=end
#SBATCH --mail-user=djprince@ucdavis.edu

mkdir 1006_thetas/

cat chub.metadata | awk '{print $1"_"$5}' | sort | uniq > 1006_thetas/pop.list

input="1006_thetas/pop.list"
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
#SBATCH -p high
#SBATCH --mem=4G
#SBATCH -o slurm_outs/0006_theta-%j.out

realSFS 1012_saf/${c1}.saf.idx -fold 1 > 1006_thetas/${c1}.sfs
realSFS saf2theta 1012_saf/${c1}.saf.idx -sfs 1006_thetas/${c1}.sfs -outname 1006_thetas/${c1}
thetaStat do_stat 1006_thetas/${c1}.thetas.idx
grep -v nan  1006_thetas/${c1}.thetas.idx.pestPG | awk '{tw+=\$4;tp+=\$5;tD+=\$9;nS+=\$14;} END{print tw/nS*1000\"\\t\"tp/nS*1000\"\\t\"tD*1000/nS;}' > 1006_thetas/${c1}.thetasperkb
" > theta_${x}.sh
sbatch theta_${x}.sh
sleep 1s
rm theta_${x}.sh

        x=$(( $x + 1 ))

done
