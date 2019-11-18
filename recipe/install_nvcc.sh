#!/bin/bash

set -xeuo pipefail

# Set `CUDA_HOME` in an activation script.
mkdir -p "${PREFIX}/etc/conda/activate.d"
cat > "${PREFIX}/etc/conda/activate.d/${PKG_NAME}_activate.sh" <<EOF
#!/bin/bash

# Backup environment variables (only if the variables are set)
if [[ ! -z "\${CUDA_HOME+x}" ]]
then
  export CUDA_HOME_CONDA_NVCC_BACKUP="\${CUDA_HOME:-}"
fi

if [[ ! -z "\${CFLAGS+x}" ]]
then
  export CFLAGS_CONDA_NVCC_BACKUP="\${CFLAGS:-}"
fi

if [[ ! -z "\${CPPFLAGS+x}" ]]
then
  export CPPFLAGS_CONDA_NVCC_BACKUP="\${CPPFLAGS:-}"
fi

if [[ ! -z "\${CXXFLAGS+x}" ]]
then
  export CXXFLAGS_CONDA_NVCC_BACKUP="\${CXXFLAGS:-}"
fi

# Default to using \$(cuda-gdb) to specify \$(CUDA_HOME).
if [[ -z "\${CUDA_HOME+x}" ]]
then
    CUDA_GDB_EXECUTABLE=\$(which cuda-gdb || exit 0)
    if [[ -n "\$CUDA_GDB_EXECUTABLE" ]]
    then
        CUDA_HOME=\$(dirname \$(dirname \$CUDA_GDB_EXECUTABLE))
    else
        echo "Cannot determine CUDA_HOME: cuda-gdb not in PATH"
        return 1
    fi
fi

if [[ ! -d "\${CUDA_HOME}" ]]
then
    echo "Directory specified in CUDA_HOME(=\${CUDA_HOME}) doesn't exist"
    return 1
fi

if [[ ! -f "\${CUDA_HOME}/lib64/stubs/libcuda.so" ]]
then
    echo "File \${CUDA_HOME}/lib64/stubs/libcuda.so doesn't exist"
    return 1
fi

if [[ \$(grep -q "CUDA Version ${PKG_VERSION}" \${CUDA_HOME}/version.txt) -ne 0 ]]
then
    echo "Version of installed CUDA didn't match package"
    return 1
fi

export CUDA_HOME="\${CUDA_HOME}"
export CFLAGS="\${CFLAGS} -I\${CUDA_HOME}/include"
export CPPFLAGS="\${CPPFLAGS} -I\${CUDA_HOME}/include"
export CXXFLAGS="\${CXXFLAGS} -I\${CUDA_HOME}/include"

mkdir -p "\${CONDA_BUILD_SYSROOT}/lib"

# Add \$(libcuda.so) shared object stub to the compiler sysroot.
# Needed for things that want to link to \$(libcuda.so).
# Stub is used to avoid getting driver code linked into binaries.

# Make a backup of \$(libcuda.so) if it exists
if [[ -f "\${CONDA_BUILD_SYSROOT}/lib/libcuda.so" ]]
then
  LIBCUDA_SO_CONDA_NVCC_BACKUP="\${CONDA_BUILD_SYSROOT}/lib/libcuda.so-conda-nvcc-backup"
  mv "\${CONDA_BUILD_SYSROOT}/lib/libcuda.so" "\${LIBCUDA_SO_CONDA_NVCC_BACKUP}"
fi
ln -s "\${CUDA_HOME}/lib64/stubs/libcuda.so" "\${CONDA_BUILD_SYSROOT}/lib/libcuda.so"

EOF

# Unset `CUDA_HOME` in a deactivation script.
mkdir -p "${PREFIX}/etc/conda/deactivate.d"
cat > "${PREFIX}/etc/conda/deactivate.d/${PKG_NAME}_deactivate.sh" <<EOF
#!/bin/bash

# Restore environment variables (if there is anything to restore)
if [[ ! -z "\${CUDA_HOME_CONDA_NVCC_BACKUP+x}" ]]
then
  export CUDA_HOME="\${CUDA_HOME_CONDA_NVCC_BACKUP}"
  unset CUDA_HOME_CONDA_NVCC_BACKUP
fi

if [[ ! -z "\${CFLAGS_CONDA_NVCC_BACKUP+x}" ]]
then
  export CFLAGS="\${CFLAGS_CONDA_NVCC_BACKUP}"
  unset CFLAGS_CONDA_NVCC_BACKUP
fi

if [[ ! -z "\${CPPFLAGS_CONDA_NVCC_BACKUP+x}" ]]
then
  export CPPFLAGS="\${CPPFLAGS_CONDA_NVCC_BACKUP}"
  unset CPPFLAGS_CONDA_NVCC_BACKUP
fi

if [[ ! -z "\${CXXFLAGS_CONDA_NVCC_BACKUP+x}" ]]
then
  export CXXFLAGS="\${CXXFLAGS_CONDA_NVCC_BACKUP}"
  unset CXXFLAGS_CONDA_NVCC_BACKUP
fi

# Remove or restore \$(libcuda.so) shared object stub from the compiler sysroot.
LIBCUDA_SO_CONDA_NVCC_BACKUP="\${CONDA_BUILD_SYSROOT}/lib/libcuda.so-conda-nvcc-backup"
if [[ -f ""\${LIBCUDA_SO_CONDA_NVCC_BACKUP}"" ]]
then
  mv -f "\${LIBCUDA_SO_CONDA_NVCC_BACKUP}" "\${CONDA_BUILD_SYSROOT}/lib/libcuda.so"
else
  rm -f "\${CONDA_BUILD_SYSROOT}/lib/libcuda.so"
fi
EOF

# Create `nvcc` script in `bin` so it can be easily run.
mkdir -p "${PREFIX}/bin"
cat > "${PREFIX}/bin/nvcc" <<EOF
#!/bin/bash
"\${CUDA_HOME}/bin/nvcc" -ccbin "\${CXX}" \$@
EOF
chmod +x "${PREFIX}/bin/nvcc"
