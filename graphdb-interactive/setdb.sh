#!/bin/bash

# SF=1000
SF=100
# SF=1

shm_size=128g
GRAPHDB_HEAP_SIZE=128g

PYENV_NAME=ldbc_datagen_tools
REPO_DIR=`pwd`/repo/
SCRIPT_DIR=`pwd`/graphdb-interactive/
BENCHMARK_DIR=${REPO_DIR}/ldbc_snb_interactive_impls_graphdb/graphdb
GRAPHDB_CSV_DIR=/mnt/disk1/geonho/graphdb/out-interactive-sf${SF}
GRAPHDB_CONTAINER_ROOT=/mnt/disk1/geonho/graphdb/data-interactive-sf${SF}
GRAPHDB_DATA_DIR=${GRAPHDB_CONTAINER_ROOT}/data
GRAPHDB_ENV_VARS=""

echo "=============================================================="
echo "Setting driver setting"
echo "=============================================================="
sed -i "27s@.*@ldbc.snb.interactive.updates_dir=${GRAPHDB_CSV_DIR}/update_streams@g" ${SCRIPT_DIR}/driver/benchmark.properties.base
sed -i "28s@.*@ldbc.snb.interactive.parameters_dir=${GRAPHDB_CSV_DIR}/substitution_parameters@g" ${SCRIPT_DIR}/driver/benchmark.properties.base
sed -i "32s@.*@ldbc.snb.interactive.scale_factor=${SF}@g" ${SCRIPT_DIR}/driver/benchmark.properties.base

sed -i "28s@.*@ldbc.snb.interactive.updates_dir=${GRAPHDB_CSV_DIR}/update_streams@g" ${SCRIPT_DIR}/driver/create-validation-parameters.properties.base 
sed -i "29s@.*@ldbc.snb.interactive.parameters_dir=${GRAPHDB_CSV_DIR}/substitution_parameters@g" ${SCRIPT_DIR}/driver/create-validation-parameters.properties.base 
sed -i "33s@.*@ldbc.snb.interactive.scale_factor=${SF}@g" ${SCRIPT_DIR}/driver/create-validation-parameters.properties.base 

sed -i "27s@.*@ldbc.snb.interactive.parameters_dir=${GRAPHDB_CSV_DIR}/substitution_parameters@g" ${SCRIPT_DIR}/driver/validate.properties.base
sed -i "31s@.*@ldbc.snb.interactive.scale_factor=${SF}@g" ${SCRIPT_DIR}/driver/validate.properties.base


cd ${BENCHMARK_DIR}
echo "=============================================================="
echo "Setting directory setting"
echo "=============================================================="
rm scripts/vars.sh
cp scripts/vars.sh.base scripts/vars.sh

sed -i "s@(GRAPHDB_CONTAINER_ROOT)@${GRAPHDB_CONTAINER_ROOT}@g" scripts/vars.sh
sed -i "s@(GRAPHDB_IMPORT_TTL_DIR)@${GRAPHDB_CSV_DIR}/social_network@g" scripts/vars.sh
sed -i "s@(GRAPHDB_HEAP_SIZE)@${GRAPHDB_HEAP_SIZE}@g" scripts/vars.sh
sed -i "s@(GRAPHDB_ENV_VARS)@${GRAPHDB_ENV_VARS}@g" scripts/vars.sh

echo "=============================================================="
echo "Setting docker environment"
echo "=============================================================="
sed -i "s@(GRAPHDB_SHM_SIZE)@${shm_size}@g" scripts/vars.sh


echo "=============================================================="
echo "Setting graphdb environment"
echo "=============================================================="


echo "=============================================================="
echo "Create database container"
echo "=============================================================="
if [ $1 = "init" ]; then
    sudo rm -rf ${GRAPHDB_CONTAINER_ROOT}
    mkdir -p ${GRAPHDB_CONTAINER_ROOT}/data
    mkdir -p ${GRAPHDB_CONTAINER_ROOT}/backup

    pyenv local ${PYENV_NAME}
    chmod +x scripts/*.sh
    scripts/one-step-load.sh
    scripts/backup-database.sh
    pyenv local system
fi

if [ $1 = "recycle" ]; then
    pyenv local ${PYENV_NAME}
    chmod +x scripts/*.sh
    scripts/restore-database.sh
    pyenv local system
fi