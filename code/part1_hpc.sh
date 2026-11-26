#!/bin/bash
#PBS -l walltime=00:30:00
#PBS -l select=1:ncpus=1:mem=1gb

module load tools/prod
module load R/4.4.1-gfbf-2023b

echo "R is about to run"
R --vanilla < $HOME/part1_hpc.R
echo "R has finished running"