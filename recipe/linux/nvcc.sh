#!/bin/bash

for arg in "${@}" ; do
  case ${arg} in -ccbin)
    # If -ccbin argument is already provided, don't add an additional one.
    exec "${CUDA_HOME}/bin/nvcc" "${@}"
  esac
done
exec "${CUDA_HOME}/bin/nvcc" -ccbin "${CXX}" "${@}"
