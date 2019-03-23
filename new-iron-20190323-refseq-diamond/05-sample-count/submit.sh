#!/bin/bash -e

#SBATCH -J count
#SBATCH -A ACORG-SL2-CPU
#SBATCH -o slurm-%A.out
#SBATCH -p skylake
#SBATCH --time=00:05:00

srun -n 1 sample-count.sh
