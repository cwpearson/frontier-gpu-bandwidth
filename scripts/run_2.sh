#!/bin/bash

#SBATCH -A CSC465
#SBATCH -J r2
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
module list > $SCOPE_RESULTS/modules.r2.$SLURM_JOBID.txt 2>&1
env > $SCOPE_RESULTS/env.r2.$SLURM_JOBID.txt

date

srun -c 56 -n 1 --gpus 8 $SCOPE_BUILD/comm_scope \
--benchmark_repetitions=5 \
--benchmark_filter='.*implicit_mapped_GPURdHost/0/.*' \
--benchmark_out_format=json \
--benchmark_out="$SCOPE_RESULTS/implicit_mapped_GPURdHost.json"

srun -c 56 -n 1 --gpus 8 $SCOPE_BUILD/comm_scope \
--benchmark_repetitions=5 \
--benchmark_filter='.*implicit_managed_HostWrGPU_fine/0/.*' \
--benchmark_out_format=json \
--benchmark_out="$SCOPE_RESULTS/implicit_managed_HostWrGPU_fine.json"

srun -c 56 -n 1 --gpus 8 $SCOPE_BUILD/comm_scope \
--benchmark_repetitions=5 \
--benchmark_filter='.*implicit_managed_HostWrGPU_coarse/0/.*' \
--benchmark_out_format=json \
--benchmark_out="$SCOPE_RESULTS/implicit_managed_HostWrGPU_coarse.json"

srun -c 56 -n 1 --gpus 8 $SCOPE_BUILD/comm_scope \
--benchmark_repetitions=5 \
--benchmark_filter='.*implicit_managed_GPUWrHost_fine/0/.*' \
--benchmark_out_format=json \
--benchmark_out="$SCOPE_RESULTS/implicit_managed_GPUWrHost_fine.json"

srun -c 56 -n 1 --gpus 8 $SCOPE_BUILD/comm_scope \
--benchmark_repetitions=5 \
--benchmark_filter='.*implicit_managed_GPUWrHost_coarse/0/.*' \
--benchmark_out_format=json \
--benchmark_out="$SCOPE_RESULTS/implicit_managed_GPUWrHost_coarse.json"

srun -c 56 -n 1 --gpus 8 $SCOPE_BUILD/comm_scope \
--benchmark_repetitions=5 \
--benchmark_filter='.*implicit_mapped_GPUWrHost/0/.*' \
--benchmark_out_format=json \
--benchmark_out="$SCOPE_RESULTS/implicit_mapped_GPUWrHost.json"

srun -c 56 -n 1 --gpus 8 $SCOPE_BUILD/comm_scope \
--benchmark_repetitions=5 \
--benchmark_filter='.*implicit_mapped_GPUWrGPU/0/.*' \
--benchmark_out_format=json \
--benchmark_out="$SCOPE_RESULTS/implicit_mapped_GPUWrGPU.json"

date
