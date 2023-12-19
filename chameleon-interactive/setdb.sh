#!/bin/bash

SF=100
shared_buffers=64GB
effective_cache_size=128GB
shm_size=128g
wal_buffers=64MB
work_mem=64MB

# SF=3000
# shared_buffers=500GB
# effective_cache_size=750GB
# shm_size=1g
# wal_buffers=64MB
# work_mem=256MB

# SF=1
# shared_buffers=4GB
# effective_cache_size=12GB
# shm_size=128g
# wal_buffers=16MB
# work_mem=6990kB

PYENV_NAME=ldbc_datagen_tools
REPO_DIR=`pwd`/repo/
SCRIPT_DIR=`pwd`/chameleon-interactive/
BENCHMARK_DIR=${REPO_DIR}/ldbc_snb_interactive_impls_chameleon/chameleon
CHAMELEON_CSV_DIR=/mnt/disk1/geonho/chameleon/out-interactive-sf${SF}/
CHAMELEON_CONTAINER_ROOT=/mnt/disk1/geonho/chameleon/data-interactive-sf${SF}
CHAMELEON_DATA_DIR=${CHAMELEON_CONTAINER_ROOT}/data
CHAMELEON_CUSTOM_CONFIGURATION=${BENCHMARK_DIR}/config/postgresql.conf
DOCKER_IMAGE_NAME=kalogon/cameleon_graph:0.0.2
CHAMELEON_VERSION=0.0.2

echo "=============================================================="
echo "Setting driver setting"
echo "=============================================================="
sed -i "31s@.*@ldbc.snb.interactive.updates_dir=${CHAMELEON_CSV_DIR}/update_streams@g" ${SCRIPT_DIR}/driver/benchmark.properties.base
sed -i "32s@.*@ldbc.snb.interactive.parameters_dir=${CHAMELEON_CSV_DIR}/substitution_parameters@g" ${SCRIPT_DIR}/driver/benchmark.properties.base
sed -i "36s@.*@ldbc.snb.interactive.scale_factor=${SF}@g" ${SCRIPT_DIR}/driver/benchmark.properties.base

sed -i "32s@.*@ldbc.snb.interactive.updates_dir=${CHAMELEON_CSV_DIR}/update_streams@g" ${SCRIPT_DIR}/driver/create-validation-parameters.properties.base 
sed -i "33s@.*@ldbc.snb.interactive.parameters_dir=${CHAMELEON_CSV_DIR}/substitution_parameters@g" ${SCRIPT_DIR}/driver/create-validation-parameters.properties.base 
sed -i "36s@.*@ldbc.snb.interactive.scale_factor=${SF}@g" ${SCRIPT_DIR}/driver/create-validation-parameters.properties.base 

sed -i "33s@.*@ldbc.snb.interactive.parameters_dir=${CHAMELEON_CSV_DIR}/substitution_parameters@g" ${SCRIPT_DIR}/driver/validate.properties.base
sed -i "37s@.*@ldbc.snb.interactive.scale_factor=${SF}@g" ${SCRIPT_DIR}/driver/validate.properties.base


cd ${BENCHMARK_DIR}
echo "=============================================================="
echo "Setting directory setting"
echo "=============================================================="
rm scripts/vars.sh
rm scripts/backup-database.sh
rm scripts/restore-database.sh
rm .env
rm docker-compose.yml
cp scripts/vars.sh.base scripts/vars.sh
cp scripts/backup-database.sh.base scripts/backup-database.sh
cp scripts/restore-database.sh.base scripts/restore-database.sh
cp .env.base .env
cp docker-compose.yml.base docker-compose.yml

sed -i "s@(CHAMELEON_DATA_DIR)@${CHAMELEON_DATA_DIR}@g" scripts/vars.sh
sed -i "s@(CHAMELEON_VERSION)@${CHAMELEON_VERSION}@g" scripts/vars.sh
sed -i "s@(CHAMELEON_CONTAINER_ROOT)@${CHAMELEON_CONTAINER_ROOT}@g" scripts/backup-database.sh
sed -i "s@(CHAMELEON_CONTAINER_ROOT)@${CHAMELEON_CONTAINER_ROOT}@g" scripts/restore-database.sh
sed -i "s@(CHAMELEON_CUSTOM_CONFIGURATION)@${CHAMELEON_CUSTOM_CONFIGURATION}@g" .env
sed -i "s@(CHAMELEON_DATA_DIR)@${CHAMELEON_DATA_DIR}@g" .env
sed -i "s@(CHAMELEON_CSV_DIR)@${CHAMELEON_CSV_DIR}@g" .env
sed -i "s@(DOCKER_IMAGE_NAME)@${DOCKER_IMAGE_NAME}@g" .env
export CHAMELEON_CSV_DIR=${CHAMELEON_CSV_DIR}
export CHAMELEON_CUSTOM_CONFIGURATION=${CHAMELEON_CUSTOM_CONFIGURATION}

echo "=============================================================="
echo "Setting docker environment"
echo "=============================================================="
sed -i "s@(shm_size)@${shm_size}@g" docker-compose.yml
sed -i "s@(CHAMELEON_DATA_DIR)@${CHAMELEON_DATA_DIR}@g" docker-compose.yml


echo "=============================================================="
echo "Setting postgres environment"
echo "=============================================================="
rm config/postgresql.conf
cp config/postgresql.conf.base config/postgresql.conf
sed -i "s/(shared_buffers)/${shared_buffers}/g" config/postgresql.conf
sed -i "s/(effective_cache_size)/${effective_cache_size}/g" config/postgresql.conf
sed -i "s/(wal_buffers)/${wal_buffers}/g" config/postgresql.conf
sed -i "s/(work_mem)/${work_mem}/g" config/postgresql.conf

echo "=============================================================="
echo "Create database container"
echo "=============================================================="
if [ $1 = "init" ]; then
    sudo rm -rf ${CHAMELEON_CONTAINER_ROOT}
    mkdir -p ${CHAMELEON_CONTAINER_ROOT}/data

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