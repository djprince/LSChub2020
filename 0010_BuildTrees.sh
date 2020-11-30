#!/bin/bash -l
#SBATCH -t 48:00:00


	mkdir 1010_trees/


echo "#!/bin/bash -l"> tree.sh

#convert fasta to phylip input		
echo "#SBATCH -o slurm_outs/0010_tree-%j.out
job=\$SLURM_ARRAY_TASK_ID
cd 1009_treeGenos/cons_seq/
nInd=\$(grep \">\" TreeGeno_cons_\${job}.fa | wc -l | awk '{print \$1}')
nBases1=\$(head -n 2 TreeGeno_cons_\${job}.fa | tail -n 1 | wc | awk '{print \$3}')
nBases=\$((\$nBases1-1))
echo -e \"\t\${nInd}\t\${nBases}\" > TreeGeno_cons_\${job}.phy
cat TreeGeno_cons_\${job}.fa | tr \"\\n\" \"(\" | sed 's/(>/\\n/g' | sed 's/(/    /' | sed 's/_//' | sed 's/>//' | sed 's/(//' >> TreeGeno_cons_\${job}.phy" >> tree.sh

#set dummy outfiles to prompt call for input/output file names in phylip
echo "echo \"fill\" > outfile
echo \"fill\" > outtree
rm TreeGeno_cons_\${job}.phy.out*" >> tree.sh

#set phylip input parameters
echo "echo \"TreeGeno_cons_\${job}.phy
F
TreeGeno_cons_\${job}.phy.outfile
V
1
J
111
3
Y
F
../../1010_trees/TreeGeno_cons_\${job}.phy.outtree\" > TreeGeno_cons_\${job}.param.in" >> tree.sh


echo "srun -t 2-00:00:00 --mem 8G phylip dnapars < TreeGeno_cons_\${job}.param.in > TreeGeno_cons_\${job}.phystdout" >> tree.sh
        
		sbatch -t 48:00:00 --array=1-1000  tree.sh
