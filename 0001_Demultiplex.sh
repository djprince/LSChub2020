#!/bin/bash
#SBATCH -o slurm_outs/0001_Demultiplex-%j.out
#SBATCH -t 25:00

echo "#!/bin/bash
#SBATCH -t 48:00:00
#SBATCH -o slurm_outs/0001_dmplx1-%j.out
1000_scripts/run_BestRadSplit.sh 1001_sequence/plates/CAACATAT_R1.fastq 1001_sequence/plates/CAACATAT_R2.fastq 1001_sequence/CAACATAT_ " > dmplx1.sh
sbatch dmplx1.sh
rm dmplx1.sh

echo "#!/bin/bash
#SBATCH -t 48:00:00 
#SBATCH -o slurm_outs/0001_dmplx2-%j.out
1000_scripts/run_BestRadSplit.sh 1001_sequence/plates/GTGCATAT_R1.fastq 1001_sequence/plates/GTGCATAT_R2.fastq 1001_sequence/GTGCATAT_ " > dmplx2.sh
sbatch dmplx2.sh
rm dmplx2.sh

echo "#!/bin/bash
#SBATCH -t 48:00:00 
#SBATCH -o slurm_outs/0001_dmplx3-%j.out
1000_scripts/run_BestRadSplit.sh 1001_sequence/plates/TTTGATAT_R1.fastq 1001_sequence/plates/TTTGATAT_R2.fastq 1001_sequence/TTTGATAT_ " > dmplx3.sh
sbatch dmplx3.sh
rm dmplx3.sh
