#!/bin/bash

PYENV_NAME=ldbc_datagen_tools
REPO_DIR=`pwd`/repo/
BENCHMARK_DIR=${REPO_DIR}/ldbc_snb_interactive_impls_graphdb/graphdb

echo "=============================================================="
echo "Copy interactive implement repository"
echo "=============================================================="
rm -rf ${REPO_DIR}/ldbc_snb_interactive_impls_graphdb
cp -r ${REPO_DIR}/ldbc_snb_interactive_impls-1.0.0 ${REPO_DIR}/ldbc_snb_interactive_impls_graphdb
cd ${BENCHMARK_DIR}
chmod +x ./scripts/*.sh

echo "=============================================================="
echo "Copy environment files"
echo "=============================================================="
cp scripts/vars.sh scripts/vars.sh.base
rm scripts/vars.sh