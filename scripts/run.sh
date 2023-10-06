#!/bin/bash

#SBATCH -A CSC465
#SBATCH -J frontier-gpu-bandwidth
#SBATCH -o %x-%j.out
#SBATCH -t 1:00:00
#SBATCH -p batch
#SBATCH -N 1

# export ROOT=/lustre/orion/CSC465/scratch/cpearson/frontier-gpu-bandwidth
export ROOT=$HOME/frontier-gpu-bandwidth
export SCOPE_SRC=${ROOT}/comm_scope
export SCOPE_BUILD=${ROOT}/build
export SCOPE_RESULTS=${ROOT}/run

module load PrgEnv-amd/8.3.3
export HSA_XNACK=1

mkdir -p $SCOPE_RESULTS
module list > $SCOPE_RESULTS/modules.$SLURM_JOBID.txt 2>&1
env > $SCOPE_RESULTS/env.$SLURM_JOBID.txt

srun -c 56 -n 1 --gpus 8 $SCOPE_BUILD/comm_scope \
--benchmark_list_tests
