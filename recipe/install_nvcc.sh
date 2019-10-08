#!/bin/bash

set -xeuo pipefail

# Set `CUDA_HOME` in an activation script.
mkdir -p "${PREFIX}/etc/conda/activate.d"
cat >"${PREFIX}/etc/conda/activate.d/${PKG_NAME}_activate.sh" <<EOF
#!/bin/bash

export CUDA_HOME_CONDA_NVCC_BACKUP="\${CUDA_HOME:-}"
export CFLAGS_CONDA_NVCC_BACKUP="\${CFLAGS:-}"
export CPPFLAGS_CONDA_NVCC_BACKUP="\${CPPFLAGS:-}"
export CXXFLAGS_CONDA_NVCC_BACKUP="\${CXXFLAGS:-}"

# Default to using \$(cuda-gdb) to specify \$(CUDA_HOME).
if [ -z \${CUDA_HOME+x} ]
then
    CUDA_GDB_EXECUTABLE=\$(which cuda-gdb)
    if [ -n "\$CUDA_GDB_EXECUTABLE" ]; then
        CUDA_HOME=\$(dirname \$(dirname \$CUDA_GDB_EXECUTABLE))
    else
        echo "Cannot determine CUDA_HOME: cuda-gdb not in PATH"
        exit 1
    fi
fi

if [[ ! -d "\${CUDA_HOME}" ]]
then
    echo "Directory \${CUDA_HOME} doesn't exist"
    exit 1
fi

if [[ ! -f "\${CUDA_HOME}/lib64/stubs/libcuda.so" ]]
then
    echo "File \${CUDA_HOME}/lib64/stubs/libcuda.so doesn't exist"
    exit 1
fi

if [[ \$(grep -q "CUDA Version ${PKG_VERSION}" \${CUDA_HOME}/version.txt) -ne 0 ]]; then
    echo "Version of installed CUDA didn't match package"
    exit 1
fi

export CUDA_HOME="\${CUDA_HOME}"
export CFLAGS="\${CFLAGS} -I\${CUDA_HOME}/include"
export CPPFLAGS="\${CPPFLAGS} -I\${CUDA_HOME}/include"
export CXXFLAGS="\${CXXFLAGS} -I\${CUDA_HOME}/include"

# Add \$(libcuda.so) shared object stub to the compiler sysroot.
# Needed for things that want to link to \$(libcuda.so).
# Stub is used to avoid getting driver code linked into binaries.

CONDA_ENV_SYSROOT="\$(\${CC} --print-sysroot)"
mkdir -p "\${CONDA_ENV_SYSROOT}/lib"
ln -s "\${CUDA_HOME}/lib64/stubs/libcuda.so" "\${CONDA_ENV_SYSROOT}/lib/libcuda.so"
EOF

# Unset `CUDA_HOME` in a deactivation script.
mkdir -p "${PREFIX}/etc/conda/deactivate.d"
cat >"${PREFIX}/etc/conda/deactivate.d/${PKG_NAME}_deactivate.sh" <<EOF
#!/bin/bash

export CUDA_HOME="\${CUDA_HOME_CONDA_NVCC_BACKUP}"
export CFLAGS="\${CFLAGS_CONDA_NVCC_BACKUP}"
export CPPFLAGS="\${CPPFLAGS_CONDA_NVCC_BACKUP}"
export CXXFLAGS="\${CXXFLAGS_CONDA_NVCC_BACKUP}"
unset CUDA_HOME_CONDA_NVCC_BACKUP
unset CFLAGS_CONDA_NVCC_BACKUP
unset CPPFLAGS_CONDA_NVCC_BACKUP
unset CXXFLAGS_CONDA_NVCC_BACKUP

if [ -z "\${CUDA_HOME+x}" ]; then
    unset CUDA_HOME
fi

if [ -z "\${CFLAGS+x}" ]; then
    unset CFLAGS
fi

if [ -z "\${CPPFLAGS+x}" ]; then
    unset CPPFLAGS
fi

if [ -z "\${CXXFLAGS+x}" ]; then
    unset CXXFLAGS
fi

# Remove \$(libcuda.so) shared object stub from the compiler sysroot.
CONDA_ENV_SYSROOT="\$(\${CC} --print-sysroot)"
rm -f "\${CONDA_ENV_SYSROOT}/lib/libcuda.so"
EOF

# Create `nvcc` script in `bin` so it can be easily run.
mkdir -p "${PREFIX}/bin"
cat >"${PREFIX}/bin/nvcc" <<EOF
#!/bin/bash
"\${CUDA_HOME}/bin/nvcc" -ccbin "\${CXX}" \$@
EOF
chmod +x "${PREFIX}/bin/nvcc"
