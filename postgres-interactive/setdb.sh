#!/bin/bash

# SF=1000
# shm_size=512g

SF=100
shm_size=512g

# SF=1
# shm_size=16g

PYENV_NAME=ldbc_datagen_tools
REPO_DIR=`pwd`/repo/
SCRIPT_DIR=`pwd`/postgres-interactive/
BENCHMARK_DIR=${REPO_DIR}/ldbc_snb_interactive_impls_postgres/postgres
POSTGRES_CSV_DIR=/mnt/disk1/geonho/postgres/out-interactive-sf${SF}
POSTGRES_CONTAINER_ROOT=/mnt/disk1/geonho/postgres/data-interactive-sf${SF}
POSTGRES_DATA_DIR=${POSTGRES_CONTAINER_ROOT}/data
POSTGRES_CUSTOM_CONFIGURATION=${BENCHMARK_DIR}/config/postgresql.conf

echo "=============================================================="
echo "Setting driver setting"
echo "=============================================================="
sed -i "31s@.*@ldbc.snb.interactive.updates_dir=${POSTGRES_CSV_DIR}/update_streams@g" ${SCRIPT_DIR}/driver/benchmark.properties.base
sed -i "32s@.*@ldbc.snb.interactive.parameters_dir=${POSTGRES_CSV_DIR}/substitution_parameters@g" ${SCRIPT_DIR}/driver/benchmark.properties.base
sed -i "36s@.*@ldbc.snb.interactive.scale_factor=${SF}@g" ${SCRIPT_DIR}/driver/benchmark.properties.base

sed -i "32s@.*@ldbc.snb.interactive.updates_dir=${POSTGRES_CSV_DIR}/update_streams@g" ${SCRIPT_DIR}/driver/create-validation-parameters.properties.base 
sed -i "33s@.*@ldbc.snb.interactive.parameters_dir=${POSTGRES_CSV_DIR}/substitution_parameters@g" ${SCRIPT_DIR}/driver/create-validation-parameters.properties.base 
sed -i "36s@.*@ldbc.snb.interactive.scale_factor=${SF}@g" ${SCRIPT_DIR}/driver/create-validation-parameters.properties.base 

sed -i "33s@.*@ldbc.snb.interactive.parameters_dir=${POSTGRES_CSV_DIR}/substitution_parameters@g" ${SCRIPT_DIR}/driver/validate.properties.base
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

sed -i "s@(POSTGRES_DATA_DIR)@${POSTGRES_DATA_DIR}@g" scripts/vars.sh
sed -i "s@(POSTGRES_CONTAINER_ROOT)@${POSTGRES_CONTAINER_ROOT}@g" scripts/backup-database.sh
sed -i "s@(POSTGRES_CONTAINER_ROOT)@${POSTGRES_CONTAINER_ROOT}@g" scripts/restore-database.sh
sed -i "s@(POSTGRES_CUSTOM_CONFIGURATION)@${POSTGRES_CUSTOM_CONFIGURATION}@g" .env
sed -i "s@(POSTGRES_DATA_DIR)@${POSTGRES_DATA_DIR}@g" .env
sed -i "s@(POSTGRES_CSV_DIR)@${POSTGRES_CSV_DIR}@g" .env
export POSTGRES_CSV_DIR=${POSTGRES_CSV_DIR}
export POSTGRES_CUSTOM_CONFIGURATION=${POSTGRES_CUSTOM_CONFIGURATION}

echo "=============================================================="
echo "Setting docker environment"
echo "=============================================================="
sed -i "s@(POSTGRES_SHM_SIZE)@${shm_size}@g" scripts/vars.sh
sed -i "s@(shm_size)@${shm_size}@g" docker-compose.yml
sed -i "s@(POSTGRES_DATA_DIR)@${POSTGRES_DATA_DIR}@g" docker-compose.yml


echo "=============================================================="
echo "Setting postgres environment"
echo "=============================================================="
rm config/postgresql.conf
cp config/postgresql.conf.base config/postgresql.conf
cp ${SCRIPT_DIR}/config/postgresql.conf config/postgresql.conf

echo "=============================================================="
echo "Create database container"
echo "=============================================================="
if [ $1 = "init" ]; then
    sudo rm -rf ${POSTGRES_CONTAINER_ROOT}
    mkdir -p ${POSTGRES_CONTAINER_ROOT}/data

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