#!/bin/bash

SF=1000
shm_size=512g
heap_initial_size=128g
heap_max_size=256g
pagecache_size=512g
# SF=100
# shm_size=128g
# heap_initial_size=32g
# heap_max_size=64g
# pagecache_size=128g
# SF=10
# shm_size=128g
# heap_initial_size=32g
# heap_max_size=64g
# pagecache_size=128g
# SF=1
# shm_size=64m
# heap_initial_size=3g
# heap_max_size=5g
# pagecache_size=5g


PYENV_NAME=ldbc_datagen_tools
REPO_DIR=`pwd`/repo/
SCRIPT_DIR=`pwd`/neo4j-interactive/
BENCHMARK_DIR=${REPO_DIR}/ldbc_snb_interactive_impls_neo4j/cypher
NEO4J_CSV_DIR=/mnt/disk1/geonho/neo4j/out-interactive-sf${SF}
NEO4J_VANILLA_CSV_DIR=${NEO4J_CSV_DIR}/vanilla
NEO4J_CONVERTED_CSV_DIR=${NEO4J_CSV_DIR}/converted
NEO4J_CONTAINER_ROOT=/mnt/disk1/geonho/neo4j/data-interactive-sf${SF}

echo "=============================================================="
echo "Setting driver setting"
echo "=============================================================="
sed -i "29s@.*@ldbc.snb.interactive.updates_dir=${NEO4J_CSV_DIR}/update_streams@g" ${SCRIPT_DIR}/driver/benchmark.properties.base
sed -i "30s@.*@ldbc.snb.interactive.parameters_dir=${NEO4J_CSV_DIR}/substitution_parameters@g" ${SCRIPT_DIR}/driver/benchmark.properties.base
sed -i "34s@.*@ldbc.snb.interactive.scale_factor=${SF}@g" ${SCRIPT_DIR}/driver/benchmark.properties.base

sed -i "30s@.*@ldbc.snb.interactive.updates_dir=${NEO4J_CSV_DIR}/update_streams@g" ${SCRIPT_DIR}/driver/create-validation-parameters.properties.base 
sed -i "31s@.*@ldbc.snb.interactive.parameters_dir=${NEO4J_CSV_DIR}/substitution_parameters@g" ${SCRIPT_DIR}/driver/create-validation-parameters.properties.base 
sed -i "34s@.*@ldbc.snb.interactive.scale_factor=${SF}@g" ${SCRIPT_DIR}/driver/create-validation-parameters.properties.base 

sed -i "29s@.*@ldbc.snb.interactive.parameters_dir=${NEO4J_CSV_DIR}/substitution_parameters@g" ${SCRIPT_DIR}/driver/validate.properties.base
sed -i "32s@.*@ldbc.snb.interactive.scale_factor=${SF}@g" ${SCRIPT_DIR}/driver/validate.properties.base


cd ${BENCHMARK_DIR}
echo "=============================================================="
echo "Setting directory setting"
echo "=============================================================="
rm scripts/vars.sh
rm scripts/backup-database.sh
rm scripts/restore-database.sh
cp scripts/vars.sh.base scripts/vars.sh
cp scripts/backup-database.sh.base scripts/backup-database.sh
cp scripts/restore-database.sh.base scripts/restore-database.sh

sed -i "s@(NEO4J_CONTAINER_ROOT)@${NEO4J_CONTAINER_ROOT}@g" scripts/vars.sh
sed -i "s@(NEO4J_CONTAINER_ROOT)@${NEO4J_CONTAINER_ROOT}@g" scripts/backup-database.sh
sed -i "s@(NEO4J_CONTAINER_ROOT)@${NEO4J_CONTAINER_ROOT}@g" scripts/restore-database.sh

export NEO4J_VANILLA_CSV_DIR=${NEO4J_VANILLA_CSV_DIR}
export NEO4J_CONVERTED_CSV_DIR=${NEO4J_CONVERTED_CSV_DIR}

echo "=============================================================="
echo "Setting neo4j environment"
echo "=============================================================="
NEO4J_ENV_VARS="\"--shm-size=${shm_size} \
    --env NEO4J_dbms_memory_heap_initial_size=${heap_initial_size} \
    --env NEO4J_dbms_memory_heap_max_size=${heap_max_size} \
    --env NEO4J_dbms_memory_pagecache_size=${pagecache_size}\""

sed -i "s@(NEO4J_ENV_VARS)@${NEO4J_ENV_VARS}@g" scripts/vars.sh

echo "=============================================================="
echo "Create database container"
echo "=============================================================="
if [ $1 = "init" ]; then
    sudo rm -rf ${NEO4J_CONTAINER_ROOT}
    mkdir -p ${NEO4J_CONTAINER_ROOT}/data

    pyenv local ${PYENV_NAME}
    chmod +x scripts/*.sh
    scripts/load-in-one-step.sh
    scripts/backup-database.sh
    pyenv local system
fi

if [ $1 = "recycle" ]; then
    pyenv local ${PYENV_NAME}
    chmod +x scripts/*.sh
    scripts/restore-database.sh
    pyenv local system
fi