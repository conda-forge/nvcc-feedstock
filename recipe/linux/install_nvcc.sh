#!/bin/bash

set -xeuo pipefail

# Activation script
mkdir -p "${PREFIX}/etc/conda/activate.d"
sed -i "s/__PKG_VERSION__/$PKG_VERSION/g" linux/activate.sh
cp $RECIPE_DIR/linux/activate.sh "${PREFIX}/etc/conda/activate.d/${PKG_NAME}_activate.sh"

# Deactivation script
mkdir -p "${PREFIX}/etc/conda/deactivate.d"
cp $RECIPE_DIR/linux/deactivate.sh "${PREFIX}/etc/conda/deactivate.d/${PKG_NAME}_deactivate.sh"

# Create `nvcc` script in `bin` so it can be easily run.
mkdir -p "${PREFIX}/bin"
cp $RECIPE_DIR/linux/nvcc.sh "${PREFIX}/bin/nvcc"
chmod +x "${PREFIX}/bin/nvcc"
