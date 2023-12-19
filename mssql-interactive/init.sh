#!/bin/bash

PYENV_NAME=ldbc_datagen_tools
REPO_DIR=`pwd`/repo/
BENCHMARK_DIR=${REPO_DIR}/ldbc_snb_interactive_impls_mssql/mssql

echo "=============================================================="
echo "Copy interactive implement repository"
echo "=============================================================="
rm -rf ${REPO_DIR}/ldbc_snb_interactive_impls_mssql
cp -r ${REPO_DIR}/ldbc_snb_interactive_impls-1.0.0 ${REPO_DIR}/ldbc_snb_interactive_impls_mssql
cd ${BENCHMARK_DIR}
chmod +x ./scripts/*.sh

# pyenv local ${PYENV_NAME}
# ./scripts/install-dependencies.sh
# pyenv local system

echo "=============================================================="
echo "Copy environment files"
echo "=============================================================="
cp .env .env.base
cp docker-compose.yml docker-compose.yml.base
rm .env
rm docker-compose.yml

echo "=============================================================="
echo "Make baseline environment files"
echo "=============================================================="
sed -i "s/True/(MSSQL_RECREATE_DB)/g" ${BENCHMARK_DIR}/.env.base
sed -i "s/.\/scratch/(MSSQL_CONTAINER_ROOT)/g" ${BENCHMARK_DIR}/.env.base
sed -i "s/\/data\/out-sf1\/graphs\/csv\/bi\/composite-merged-fk\/initial_snapshot/(MSSQL_CSV_DIR)/g" ${BENCHMARK_DIR}/.env.base