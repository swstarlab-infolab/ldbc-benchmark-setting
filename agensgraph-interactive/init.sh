#!/bin/bash

PYENV_NAME=ldbc_agensgraph
REPO_DIR=`pwd`/repo/
BENCHMARK_DIR=${REPO_DIR}/ldbc_snb_interactive_impls_agensgraph/agensgraph

echo "=============================================================="
echo "Copy interactive implement repository"
echo "=============================================================="
rm -rf ${REPO_DIR}/ldbc_snb_interactive_impls_agensgraph
cp -r ${REPO_DIR}/ldbc_snb_interactive_impls-1.0.0 ${REPO_DIR}/ldbc_snb_interactive_impls_agensgraph
cd ${BENCHMARK_DIR}
chmod +x ./scripts/*.sh
# pyenv local ${PYENV_NAME}
# ./scripts/install-dependencies.sh
# pyenv local system

echo "=============================================================="
echo "Copy environment files"
echo "=============================================================="
cp scripts/vars.sh scripts/vars.sh.base
cp scripts/backup-database.sh scripts/backup-database.sh.base
cp scripts/restore-database.sh scripts/restore-database.sh.base
cp .env .env.base
rm scripts/vars.sh
rm scripts/backup-database.sh
rm scripts/restore-database.sh
rm .env