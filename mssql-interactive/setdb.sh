#!/bin/bash

# SF=1000
# shm_size=512g

# SF=100
# shm_size=512g

SF=1
shm_size=16g

PYENV_NAME=ldbc_datagen_tools
REPO_DIR=`pwd`/repo/
SCRIPT_DIR=`pwd`/mssql-interactive/
BENCHMARK_DIR=${REPO_DIR}/ldbc_snb_interactive_impls_mssql/mssql
MSSQL_CSV_DIR=/mnt/disk1/geonho/mssql/out-interactive-sf${SF}
MSSQL_CONTAINER_ROOT=/mnt/disk1/geonho/mssql/data-interactive-sf${SF}
MSSQL_DATA_DIR=${MSSQL_CONTAINER_ROOT}/logs/
MSSQL_LOG_DIR=${MSSQL_CONTAINER_ROOT}/data/
MSSQL_SECRETS_DIR=${MSSQL_CONTAINER_ROOT}/secrets/
MSSQL_BACKUP_DIR=${MSSQL_CONTAINER_ROOT}/backup/

echo "=============================================================="
echo "Setting driver setting"
echo "=============================================================="
sed -i "30s@.*@ldbc.snb.interactive.updates_dir=${MSSQL_CSV_DIR}/update_streams@g" ${SCRIPT_DIR}/driver/benchmark.properties.base
sed -i "31s@.*@ldbc.snb.interactive.parameters_dir=${MSSQL_CSV_DIR}/substitution_parameters@g" ${SCRIPT_DIR}/driver/benchmark.properties.base
sed -i "37s@.*@ldbc.snb.interactive.scale_factor=${SF}@g" ${SCRIPT_DIR}/driver/benchmark.properties.base

sed -i "27s@.*@ldbc.snb.interactive.updates_dir=${MSSQL_CSV_DIR}/update_streams@g" ${SCRIPT_DIR}/driver/create-validation-parameters.properties.base 
sed -i "28s@.*@ldbc.snb.interactive.parameters_dir=${MSSQL_CSV_DIR}/substitution_parameters@g" ${SCRIPT_DIR}/driver/create-validation-parameters.properties.base 
sed -i "35s@.*@ldbc.snb.interactive.scale_factor=${SF}@g" ${SCRIPT_DIR}/driver/create-validation-parameters.properties.base 

sed -i "32s@.*@ldbc.snb.interactive.scale_factor=${SF}@g" ${SCRIPT_DIR}/driver/validate.properties.base


cd ${BENCHMARK_DIR}
echo "=============================================================="
echo "Setting directory setting"
echo "=============================================================="
rm .env
rm docker-compose.yml
cp .env.base .env
cp docker-compose.yml.base docker-compose.yml

sed -i "s@(MSSQL_CONTAINER_ROOT)@${MSSQL_CONTAINER_ROOT}@g" .env
sed -i "s@(MSSQL_CSV_DIR)@${MSSQL_CSV_DIR}@g" .env
sed -i "s@(MSSQL_SHM_SIZE)@${shm_size}@g" .env

if [ $1 = "init" ]; then
    sed -i "s@(MSSQL_RECREATE_DB)@True@g" .env
fi

if [ $1 = "recycle" ]; then
    sed -i "s@(MSSQL_RECREATE_DB)@False@g" .env
fi

export MSSQL_CSV_DIR=${MSSQL_CSV_DIR}

echo "=============================================================="
echo "Setting docker environment"
echo "=============================================================="

echo "=============================================================="
echo "Setting mssql environment"
echo "=============================================================="

echo "=============================================================="
echo "Create database container"
echo "=============================================================="
if [ $1 = "init" ]; then
    sudo rm -rf ${MSSQL_CONTAINER_ROOT}
    mkdir -p ${MSSQL_DATA_DIR}
    mkdir -p ${MSSQL_LOG_DIR}
    mkdir -p ${MSSQL_SECRETS_DIR}
    mkdir -p ${MSSQL_BACKUP_DIR}

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
