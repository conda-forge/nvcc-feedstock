#!/bin/bash

set -xeuo pipefail

# Set `CUDA_HOME` in an activation script.
mkdir -p "${PREFIX}/etc/conda/activate.d"
cp activate.sh ${PREFIX}/etc/conda/activate.d/${PKG_NAME}_activate.sh

# Unset `CUDA_HOME` in a deactivation script.
mkdir -p "${PREFIX}/etc/conda/deactivate.d"
cp deactivate.sh ${PREFIX}/etc/conda/deactivate.d/${PKG_NAME}_deactivate.sh

# Create `nvcc` script in `bin` so it can be easily run.
mkdir -p "${PREFIX}/bin"
cat > "${PREFIX}/bin/nvcc" <<'EOF'
#!/bin/bash
for arg in "${@}" ; do
  case ${arg} in -ccbin)
    # If -ccbin argument is already provided, don't add an additional one.
    exec "${CUDA_HOME}/bin/nvcc" "${@}"
  esac
done
exec "${CUDA_HOME}/bin/nvcc" -ccbin "${CXX}" "${@}"
EOF
chmod +x "${PREFIX}/bin/nvcc"
