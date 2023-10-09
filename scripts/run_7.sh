#!/bin/bash

#SBATCH -A CSC465
#SBATCH -J r7
#SBATCH -o %x-%j.out
#SBATCH -t 2:00:00
#SBATCH -p batch
#SBATCH -N 1

# salloc -A CSC465 -N 1 -p batch -t 2:00:00

export ROOT=/lustre/orion/csc465/scratch/cpearson/frontier-gpu-bandwidth
export SCOPE_SRC=${ROOT}/comm_scope
export SCOPE_BUILD=${ROOT}/build
export SCOPE_RESULTS=${ROOT}/run

module load PrgEnv-amd/8.3.3
export HSA_XNACK=1

mkdir -p $SCOPE_RESULTS
module list > $SCOPE_RESULTS/modules.r7.$SLURM_JOBID.txt 2>&1
env > $SCOPE_RESULTS/env.r7.$SLURM_JOBID.txt
rocm-smi > $SCOPE_RESULTS/rocm-smi.r7.$SLURM_JOBID.txt 2>&1
lscpu > $SCOPE_RESULTS/lscpu.r7.$SLURM_JOBID.txt 2>&1

date

srun -c 56 -n 1 --gpus 8 $SCOPE_BUILD/comm_scope \
--benchmark_repetitions=5 \
--benchmark_filter='.*prefetch_managed_GPUToHost/0/0/.*' \
--benchmark_out_format=json \
--benchmark_out="$SCOPE_RESULTS/prefetch_managed_GPUToHost.json"

srun -c 56 -n 1 --gpus 8 $SCOPE_BUILD/comm_scope \
--benchmark_repetitions=5 \
--benchmark_filter='.*prefetch_managed_HostToGPU/0/0/.*' \
--benchmark_out_format=json \
--benchmark_out="$SCOPE_RESULTS/prefetch_managed_HostToGPU.json"

date
