#!/bin/bash

set -euxo pipefail

# Verify the symlink to the libcuda stub library exists.
test "$(realpath $(${CC} --print-sysroot))" = "$(realpath ${CONDA_BUILD_SYSROOT})"
test -f "${CONDA_BUILD_SYSROOT}/lib/libcuda.so" || (echo "${CONDA_BUILD_SYSROOT}/lib/libcuda.so is not a file" && exit 1)

# Verify the activation scripts are in-place.
for state in "activate" "deactivate"; do
    test -f "${PREFIX}/etc/conda/${state}.d/${PKG_NAME}_${state}.sh"
done

# Try using the activation scripts.
if [ -z ${CUDA_HOME+x} ]; then
    echo "CUDA_HOME is unset after activation" && exit 1
else
    echo "CUDA_HOME is set to '$CUDA_HOME'"
fi
source ${PREFIX}/etc/conda/deactivate.d/${PKG_NAME}_deactivate.sh

if [ ! -z "${CUDA_HOME+x}" ] && [ ! -z "${TEST_CUDA_HOME_INITIAL+x}" ]; then
    echo "CUDA_HOME correctly unset after deactivation"
elif [ ! -z "${CUDA_HOME+x}" ] && [ -z "${TEST_CUDA_HOME_INITIAL+x}" ]; then
    echo "CUDA_HOME correctly maintained as '$CUDA_HOME' after deactivation"
else
    echo "CUDA_HOME is incorrectly set to '$CUDA_HOME' after deactivation" && exit 1
fi

# Set some CFLAGS to make sure we're not causing side effects
export CFLAGS_CONDA_NVCC_TEST_BACKUP="${CFLAGS}"
export CFLAGS="${CFLAGS} -I/path/to/test/include"
export CFLAGS_CONDA_NVCC_TEST="${CFLAGS}"

# Manually trigger the activation script
source ${PREFIX}/etc/conda/activate.d/${PKG_NAME}_activate.sh

# Check activation worked as expected, then deactivate
if [ -z ${CUDA_HOME+x} ]; then
    echo "CUDA_HOME is unset after activation" && exit 1
else
    echo "CUDA_HOME is set to '${CUDA_HOME}'"
fi
source ${PREFIX}/etc/conda/deactivate.d/${PKG_NAME}_deactivate.sh

# Make sure there's no side effects
if [[ "${CFLAGS}" == "${CFLAGS_CONDA_NVCC_TEST}" ]]; then
    echo "CFLAGS correctly maintained as '${CFLAGS}'"
    unset CFLAGS_CONDA_NVCC_TEST
    export CFLAGS="${CFLAGS_CONDA_NVCC_TEST_BACKUP}"
    unset CFLAGS_CONDA_NVCC_TEST_BACKUP
else
    echo "CFLAGS is incorrectly set to '${CFLAGS}', should be set to '${CFLAGS_CONDA_NVCC_TEST}'" && exit 1
fi
# Reactivate
source ${PREFIX}/etc/conda/activate.d/${PKG_NAME}_activate.sh

# Try building something
nvcc test.cu