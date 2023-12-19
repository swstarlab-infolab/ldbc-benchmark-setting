#!/bin/bash

PYENV_NAME=ldbc_datagen_tools
REPO_DIR=`pwd`/repo/
BENCHMARK_DIR=${REPO_DIR}/ldbc_snb_interactive_impls_tigergraph/tigergraph

echo "=============================================================="
echo "Copy interactive implement repository"
echo "=============================================================="
rm -rf ${REPO_DIR}/ldbc_snb_interactive_impls_tigergraph
cp -r ${REPO_DIR}/ldbc_snb_interactive_impls-1.0.0 ${REPO_DIR}/ldbc_snb_interactive_impls_tigergraph
cd ${BENCHMARK_DIR}
pyenv local ${PYENV_NAME}
pip3 install --progress-bar off psycopg
pyenv local system

echo "=============================================================="
echo "Copy environment files"
echo "=============================================================="
cp scripts/vars.sh scripts/vars.sh.base
cp scripts/backup-database.sh scripts/backup-database.sh.base
cp scripts/restore-database.sh scripts/restore-database.sh.base
cp scripts/start.sh scripts/start.sh.base
rm scripts/vars.sh
rm scripts/backup-database.sh
rm scripts/restore-database.sh
rm scripts/start.sh


echo "=============================================================="
echo "Make baseline environment files"
echo "=============================================================="
# sed -i "45 a\  --volume=(TIGERGRAPH_CONTAINER_ROOT)/backup:/home/tigergraph/backup:z \\\\"  ${BENCHMARK_DIR}/scripts/start.sh.base
# sed -i "45 a\  --volume=(TIGERGRAPH_CONTAINER_ROOT)/data:/home/tigergraph/tigergraph/data:z \\\\"  ${BENCHMARK_DIR}/scripts/start.sh.base

sed -i "s@#export TIGERGRAPH_DATA_DIR=\`pwd\`/test-data@export TIGERGRAPH_DATA_DIR=(TIGERGRAPH_DATA_DIR)@g" ${BENCHMARK_DIR}/scripts/vars.sh.base
# sed -i "s@export TIGERGRAPH_ENV_VARS=\"\"@export TIGERGRAPH_ENV_VARS=(TIGERGRAPH_ENV_VARS)@g" ${BENCHMARK_DIR}/scripts/vars.sh.base