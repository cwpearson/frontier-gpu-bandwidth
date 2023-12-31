#!/bin/bash

#SBATCH -A CSC465
#SBATCH -J r1
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
module list > $SCOPE_RESULTS/modules.r1.$SLURM_JOBID.txt 2>&1
env > $SCOPE_RESULTS/env.r1.$SLURM_JOBID.txt
rocm-smi > $SCOPE_RESULTS/rocm-smi.r1.$SLURM_JOBID.txt 2>&1
lscpu > $SCOPE_RESULTS/lscpu.r1.$SLURM_JOBID.txt 2>&1

date

srun -c 56 -n 1 --gpus 8 $SCOPE_BUILD/comm_scope \
--benchmark_repetitions=5 \
--benchmark_filter='.*hipMemcpyAsync_GPUToPinned/0/0/.*' \
--benchmark_out_format=json \
--benchmark_out="$SCOPE_RESULTS/hipMemcpyAsync_GPUToPinned.json"

srun -c 56 -n 1 --gpus 8 $SCOPE_BUILD/comm_scope \
--benchmark_repetitions=5 \
--benchmark_filter='.*hipMemcpyAsync_PinnedToGPU/0/0/.*' \
--benchmark_out_format=json \
--benchmark_out="$SCOPE_RESULTS/hipMemcpyAsync_PinnedToGPU.json"

srun -c 56 -n 1 --gpus 8 $SCOPE_BUILD/comm_scope \
--benchmark_repetitions=5 \
--benchmark_filter='.*hipMemcpyAsync_GPUToPageable/0/0/.*' \
--benchmark_out_format=json \
--benchmark_out="$SCOPE_RESULTS/hipMemcpyAsync_GPUToPageable.json"

date
