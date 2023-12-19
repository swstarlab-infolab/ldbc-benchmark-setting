#!/bin/bash

# SF=1000
# shm_size=512g

# SF=10
# shm_size=128g

SF=1
shm_size=128g

PYENV_NAME=ldbc_datagen_tools
REPO_DIR=`pwd`/repo/
SCRIPT_DIR=`pwd`/tigergraph-interactive/
BENCHMARK_DIR=${REPO_DIR}/ldbc_snb_interactive_impls_tigergraph/tigergraph
TIGERGRAPH_DATA_DIR=/mnt/disk1/geonho/tigergraph/out-interactive-sf${SF}
TIGERGRAPH_CONTAINER_ROOT=/mnt/disk1/geonho/tigergraph/data-interactive-sf${SF}
TIGERGRAPH_ENV_VARS=

echo "=============================================================="
echo "Setting tigergraph environment"
echo "=============================================================="
mkdir -p ${TIGERGRAPH_CONTAINER_ROOT}/data
mkdir -p ${TIGERGRAPH_CONTAINER_ROOT}/backup
sed -i "s@(TIGERGRAPH_CONTAINER_ROOT)@${TIGERGRAPH_CONTAINER_ROOT}@g" ${BENCHMARK_DIR}/scripts/start.sh.base

echo "=============================================================="
echo "Setting driver setting"
echo "=============================================================="
sed -i "25s@.*@ldbc.snb.interactive.parameters_dir=${TIGERGRAPH_DATA_DIR}/substitution_parameters@g" ${SCRIPT_DIR}/driver/benchmark.properties.base
sed -i "26s@.*@ldbc.snb.interactive.updates_dir=${TIGERGRAPH_DATA_DIR}/update_streams@g" ${SCRIPT_DIR}/driver/benchmark.properties.base
sed -i "31s@.*@ldbc.snb.interactive.scale_factor=${SF}@g" ${SCRIPT_DIR}/driver/benchmark.properties.base

sed -i "29s@.*@ldbc.snb.interactive.updates_dir=${TIGERGRAPH_DATA_DIR}/update_streams@g" ${SCRIPT_DIR}/driver/create-validation-parameters.properties.base 
sed -i "30s@.*@ldbc.snb.interactive.parameters_dir=${TIGERGRAPH_DATA_DIR}/substitution_parameters@g" ${SCRIPT_DIR}/driver/create-validation-parameters.properties.base 
sed -i "34s@.*@ldbc.snb.interactive.scale_factor=${SF}@g" ${SCRIPT_DIR}/driver/create-validation-parameters.properties.base 

sed -i "27s@.*@ldbc.snb.interactive.parameters_dir=${TIGERGRAPH_DATA_DIR}/substitution_parameters@g" ${SCRIPT_DIR}/driver/validate.properties.base
sed -i "30s@.*@ldbc.snb.interactive.scale_factor=${SF}@g" ${SCRIPT_DIR}/driver/validate.properties.base


cd ${BENCHMARK_DIR}
echo "=============================================================="
echo "Setting directory setting"
echo "=============================================================="
rm scripts/vars.sh
rm scripts/backup-database.sh
rm scripts/restore-database.sh
rm scripts/start.sh
cp scripts/vars.sh.base scripts/vars.sh
cp scripts/backup-database.sh.base scripts/backup-database.sh
cp scripts/restore-database.sh.base scripts/restore-database.sh
cp scripts/start.sh.base scripts/start.sh

sed -i "s@(TIGERGRAPH_DATA_DIR)@${TIGERGRAPH_DATA_DIR}@g" scripts/vars.sh
export TIGERGRAPH_DATA_DIR=${TIGERGRAPH_DATA_DIR}

echo "=============================================================="
echo "Setting docker environment"
echo "=============================================================="


echo "=============================================================="
echo "Create database container"
echo "=============================================================="
if [ $1 = "init" ]; then
    pyenv local ${PYENV_NAME}
    chmod +x scripts/*.sh
    chmod +x setup/*.sh
    scripts/load-in-one-step.sh
    scripts/backup-database.sh
    pyenv local system
fi

if [ $1 = "recycle" ]; then
    pyenv local ${PYENV_NAME}
    chmod +x scripts/*.sh
    chmod +x setup/*.sh
    scripts/restore-database.sh
    pyenv local system
fi