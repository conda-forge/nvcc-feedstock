#!/bin/bash

set -xeuo pipefail

# Set `CUDA_HOME` in an activation script.
mkdir -p "${PREFIX}/etc/conda/activate.d"
cat >"${PREFIX}/etc/conda/activate.d/${PKG_NAME}_activate.sh" <<EOF
#!/bin/bash

CUDA_HOME_UNSET=0

# Default to using \$(cuda-gdb) to specify \$(CUDA_HOME).
if [ -z \${CUDA_HOME+x} ]
then
    CUDA_HOME="\$(dirname \$(dirname \$(which cuda-gdb)))"
    CUDA_HOME_UNSET=1
fi

if [[ ! -d "\${CUDA_HOME}" ]]
then
    echo "Cannot find: \${CUDA_HOME}"
    exit 1
fi
if [[ ! -f "\${CUDA_HOME}/lib64/stubs/libcuda.so" ]]
then
    echo "Cannot find: \${CUDA_HOME}/lib64/stubs/libcuda.so"
    exit 1
fi
grep "CUDA Version ${PKG_VERSION}" \${CUDA_HOME}/version.txt &>/dev/null
if [[ \$? -ne 0 ]]
then
    echo "Version of installed CUDA didn't match package"
    exit 1
fi

export CUDA_HOME_UNSET=\${CUDA_HOME_UNSET}
export CUDA_HOME="\${CUDA_HOME}"
export CFLAGS="\${CFLAGS} -I\${CUDA_HOME}/include"
export CPPFLAGS="\${CPPFLAGS} -I\${CUDA_HOME}/include"
export CXXFLAGS="\${CXXFLAGS} -I\${CUDA_HOME}/include"

# Add \$(libcuda.so) shared object stub to the compiler sysroot.
# Needed for things that want to link to $(libcuda.so).
# Stub is used to avoid getting driver code linked into binaries.

CONDA_ENV_SYSROOT="\$(\${CC} --print-sysroot)"
mkdir -p "\${CONDA_ENV_SYSROOT}/lib"
ln -s "\${CUDA_HOME}/lib64/stubs/libcuda.so" "\${CONDA_ENV_SYSROOT}/lib/libcuda.so"
EOF

# Unset `CUDA_HOME` in a deactivation script.
mkdir -p "${PREFIX}/etc/conda/deactivate.d"
cat >"${PREFIX}/etc/conda/deactivate.d/${PKG_NAME}_deactivate.sh" <<EOF
#!/bin/bash

if [[ "$CUDA_HOME_UNSET" -eq "1" ]]
then
    unset CUDA_HOME
fi
unset CUDA_HOME_UNSET
unset CFLAGS
unset CPPFLAGS
unset CXXFLAGS

# Remove \$(libcuda.so) shared object stub from the compiler sysroot.
CONDA_ENV_SYSROOT="\$(\${CC} --print-sysroot)"
rm -f "\${CONDA_ENV_SYSROOT}/lib/libcuda.so"
EOF

# Create `nvcc` script in `bin` so it can be easily run.
mkdir -p "${PREFIX}/bin"
cat >"${PREFIX}/bin/nvcc" <<'EOF'
#!/bin/bash
"\${CUDA_HOME}/bin/nvcc" -ccbin "\${CXX}" \$@
EOF
chmod +x "${PREFIX}/bin/nvcc"
