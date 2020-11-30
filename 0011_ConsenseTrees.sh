#!/bin/bash -l
#SBATCH -t 48:00:00
#SBATCH -o slurm_outs/0010_ConsTree--%j.out


echo "#!/bin/bash -l
#SBATCH -o slurm_outs/0010_cons-%j.out
mkdir 1011_consensedTree
cat 1010_trees/*outtree > 1011_consensedTree/cat1k.outtree
cd 1011_consensedTree/" > cons_tree.sh

#set dummy outfiles to prompt call for input/output file names in phylip
echo "echo \"fill\" > outfile
echo \"fill\" > outtree
rm constree.out*" >> cons_tree.sh

#set phylip input parameters
echo "echo \"cat1k.outtree
F
1k_constree.outfile
y
F
1k_constree.outtree\" > consparam.in" >> cons_tree.sh


echo "srun -p high -t 48:00:00 --mem 8G phylip consense < consparam.in > 1k_constree.phystdout" >> cons_tree.sh
       

 
		sbatch -p high -t 2-00:00:00  cons_tree.sh

		rm cons_tree.sh

