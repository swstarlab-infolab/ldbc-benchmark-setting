#!/bin/bash

# SF=100
# shared_buffers=64GB
# effective_cache_size=128GB
# shm_size=128g
# wal_buffers=64MB
# work_mem=64MB

# SF=3000
# shared_buffers=500GB
# effective_cache_size=750GB
# shm_size=1g
# wal_buffers=64MB
# work_mem=256MB

SF=1
shared_buffers=4GB
effective_cache_size=12GB
shm_size=128g
wal_buffers=16MB
work_mem=6990kB

PYENV_NAME=ldbc_datagen_tools
REPO_DIR=`pwd`/repo/
SCRIPT_DIR=`pwd`/age-interactive/
BENCHMARK_DIR=${REPO_DIR}/ldbc_snb_interactive_impls_age/age
POSTGRES_CSV_DIR=/mnt/disk1/geonho/age/out-interactive-sf${SF}
AGE_CSV_DIR=/mnt/disk1/geonho/age/out-age-interactive-sf${SF}
POSTGRES_DATA_DIR=/mnt/disk1/geonho/age/data-interactive-sf${SF}
POSTGRES_CUSTOM_CONFIGURATION=${BENCHMARK_DIR}/config/postgresql.conf
DOCKER_IMAGE_NAME=apache/age

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


sudo rm -rf ${POSTGRES_DATA_DIR}
mkdir -p ${POSTGRES_DATA_DIR}
cd ${BENCHMARK_DIR}
echo "=============================================================="
echo "Setting directory setting"
echo "=============================================================="
rm scripts/vars.sh
rm .env
rm docker-compose.yml
cp scripts/vars.sh.base scripts/vars.sh
cp .env.base .env
cp docker-compose.yml.base docker-compose.yml

sed -i "s@(POSTGRES_DATA_DIR)@${POSTGRES_DATA_DIR}@g" scripts/vars.sh
sed -i "s@(POSTGRES_CUSTOM_CONFIGURATION)@${POSTGRES_CUSTOM_CONFIGURATION}@g" .env
sed -i "s@(POSTGRES_DATA_DIR)@${POSTGRES_DATA_DIR}@g" .env
sed -i "s@(POSTGRES_CSV_DIR)@${POSTGRES_CSV_DIR}@g" .env
sed -i "s@(DOCKER_IMAGE_NAME)@${DOCKER_IMAGE_NAME}@g" .env
sed -i "3 i AGE_CSV_DIR=${AGE_CSV_DIR}" .env
export POSTGRES_CSV_DIR=${POSTGRES_CSV_DIR}
export AGE_CSV_DIR=${AGE_CSV_DIR}
export POSTGRES_CUSTOM_CONFIGURATION=${POSTGRES_CUSTOM_CONFIGURATION}

echo "=============================================================="
echo "Setting docker environment"
echo "=============================================================="
sed -i "s@(shm_size)@${shm_size}@g" docker-compose.yml
sed -i "s@(POSTGRES_DATA_DIR)@${POSTGRES_DATA_DIR}@g" docker-compose.yml


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
pyenv local ${PYENV_NAME}
docker stop snb-interactive-age
docker rm snb-interactive-age
docker-compose build && sudo docker-compose up -d
pyenv local system

echo "=============================================================="
echo "post setdb setting"
echo "=============================================================="
# docker exec --user root -it snb-interactive-age bash
# apt-get update && apt-get install openssh-client git bc
# ssh-keygen and clone git repository