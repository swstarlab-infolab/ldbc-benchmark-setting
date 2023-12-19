#!/bin/bash

AGENS_VERSION=2.1.3
# SF=1000
# shm_size=512g

# SF=300
# shm_size=128g

SF=100
shm_size=64g

# SF=10
# shm_size=64g

# SF=1
# shm_size=64g

# SF=0.1
# shm_size=64g

# SF=10
# shared_buffers=64GB
# effective_cache_size=128GB
# shm_size=128g
# wal_buffers=64MB
# work_mem=64MB

# SF=1
# shared_buffers=4GB
# effective_cache_size=12GB
# shm_size=128g
# wal_buffers=16MB
# work_mem=6990kB

PYENV_NAME=ldbc_agensgraph
REPO_DIR=`pwd`/repo/
SCRIPT_DIR=`pwd`/agensgraph-interactive/
BENCHMARK_DIR=${REPO_DIR}/ldbc_snb_interactive_impls_agensgraph/agensgraph
AGENS_OUT_DIR=/mnt/disk1/geonho/agensgraph/out-interactive-sf${SF}
AGENS_UPDATE_DIR=${AGENS_OUT_DIR}/update_streams
AGENS_PARAM_DIR=${AGENS_OUT_DIR}/substitution_parameters
AGENS_CSV_DIR=${AGENS_OUT_DIR}/csv
AGENS_CONTAINER_ROOT=/mnt/disk1/geonho/agensgraph/data-interactive-sf${SF}
AGENS_DATA_DIR=${AGENS_CONTAINER_ROOT}/data
AGENS_CUSTOM_CONFIGURATION=${BENCHMARK_DIR}/config/postgresql.conf

echo "=============================================================="
echo "Setting driver setting"
echo "=============================================================="
sed -i "31s@.*@ldbc.snb.interactive.updates_dir=${AGENS_UPDATE_DIR}@g" ${SCRIPT_DIR}/driver/benchmark.properties.base
sed -i "32s@.*@ldbc.snb.interactive.parameters_dir=${AGENS_PARAM_DIR}@g" ${SCRIPT_DIR}/driver/benchmark.properties.base
sed -i "36s@.*@ldbc.snb.interactive.scale_factor=${SF}@g" ${SCRIPT_DIR}/driver/benchmark.properties.base

sed -i "32s@.*@ldbc.snb.interactive.updates_dir=${AGENS_UPDATE_DIR}@g" ${SCRIPT_DIR}/driver/create-validation-parameters.properties.base 
sed -i "33s@.*@ldbc.snb.interactive.parameters_dir=${AGENS_PARAM_DIR}@g" ${SCRIPT_DIR}/driver/create-validation-parameters.properties.base 
sed -i "36s@.*@ldbc.snb.interactive.scale_factor=${SF}@g" ${SCRIPT_DIR}/driver/create-validation-parameters.properties.base 

sed -i "33s@.*@ldbc.snb.interactive.parameters_dir=${AGENS_PARAM_DIR}@g" ${SCRIPT_DIR}/driver/validate.properties.base
sed -i "37s@.*@ldbc.snb.interactive.scale_factor=${SF}@g" ${SCRIPT_DIR}/driver/validate.properties.base


cd ${BENCHMARK_DIR}
echo "=============================================================="
echo "Setting directory setting"
echo "=============================================================="
rm scripts/vars.sh
rm scripts/backup-database.sh
rm scripts/restore-database.sh
rm .env
cp scripts/vars.sh.base scripts/vars.sh
cp scripts/backup-database.sh.base scripts/backup-database.sh
cp scripts/restore-database.sh.base scripts/restore-database.sh
cp .env.base .env

sed -i "s@(AGENS_CONTAINER_ROOT)@${AGENS_CONTAINER_ROOT}@g" scripts/vars.sh
sed -i "s@(AGENS_CSV_DIR)@${AGENS_CSV_DIR}@g" scripts/vars.sh
sed -i "s@(AGENS_DATA_DIR)@${AGENS_DATA_DIR}@g" scripts/vars.sh
sed -i "s@(AGENS_VERSION)@${AGENS_VERSION}@g" scripts/vars.sh
sed -i "s@(AGENS_CONTAINER_ROOT)@${AGENS_CONTAINER_ROOT}@g" scripts/backup-database.sh
sed -i "s@(AGENS_CONTAINER_ROOT)@${AGENS_CONTAINER_ROOT}@g" scripts/restore-database.sh
sed -i "s@(AGENS_CUSTOM_CONFIGURATION)@${AGENS_CUSTOM_CONFIGURATION}@g" .env
sed -i "s@(AGENS_DATA_DIR)@${AGENS_DATA_DIR}@g" .env
sed -i "s@(AGENS_CSV_DIR)@${AGENS_CSV_DIR}@g" .env
export INTEGRATE_MODE=${INTEGRATE_MODE}
export AGENS_CSV_DIR=${AGENS_CSV_DIR}
export AGENS_CUSTOM_CONFIGURATION=${AGENS_CUSTOM_CONFIGURATION}

echo "=============================================================="
echo "Setting docker environment"
echo "=============================================================="
sed -i "s@(AGENS_SHM_SIZE)@${shm_size}@g" scripts/vars.sh


echo "=============================================================="
echo "Setting postgres environment"
echo "=============================================================="
cp ${SCRIPT_DIR}/config/postgresql.conf config/postgresql.conf

echo "=============================================================="
echo "Create database container"
echo "=============================================================="
if [ $1 = "init" ]; then
    sudo rm -rf ${AGENS_CONTAINER_ROOT}
    mkdir -p ${AGENS_CONTAINER_ROOT}/data

    pyenv local ${PYENV_NAME}
    chmod +x scripts/*.sh
    scripts/load-in-one-step.sh
    scripts/backup-database.sh
    # docker stop postgres-db-loader
    # docker rm postgres-db-loader
    # docker stop snb-interactive-postgres
    # docker rm snb-interactive-postgres
    # docker-compose build && sudo docker-compose up -d
    pyenv local system
fi

if [ $1 = "recycle" ]; then
    pyenv local ${PYENV_NAME}
    chmod +x scripts/*.sh
    scripts/restore-database.sh
    pyenv local system
fi