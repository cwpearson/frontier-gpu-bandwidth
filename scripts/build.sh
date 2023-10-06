#!/bin/bash

set -eou pipefail

# export ROOT=/lustre/orion/CSC465/scratch/cpearson/frontier-gpu-bandwidth
export ROOT=$HOME/frontier-gpu-bandwidth
export SCOPE_SRC=${ROOT}/comm_scope
export SCOPE_BUILD=${ROOT}/build

git clone --recursive git@github.com:c3sr/comm_scope.git $SCOPE_SRC || true
cd $SCOPE_SRC && git checkout d744349

module load PrgEnv-amd/8.3.3

rm -rf $SCOPE_BUILD
mkdir -p $SCOPE_BUILD
module list > $SCOPE_BUILD/modules.txt 2>&1
env > $SCOPE_BUILD/env.txt
cmake \
-S $SCOPE_SRC \
-B $SCOPE_BUILD \
-D CMAKE_CXX_COMPILER=hipcc \
-D CMAKE_BUILD_TYPE=Release \
-D SCOPE_ARCH_MI250X=ON \
-D SCOPE_USE_NUMA=ON \
-D CMAKE_CXX_FLAGS="--amdgpu-target=gfx90a:xnack+" \
| tee $SCOPE_BUILD/configure.log 2>&1

nice -n20 make -C ${SCOPE_BUILD} -j16 \
| tee ${SCOPE_BUILD}/build.log 2>&1

