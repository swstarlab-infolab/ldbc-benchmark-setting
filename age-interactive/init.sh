#!/bin/bash

PYENV_NAME=ldbc_datagen_tools
REPO_DIR=`pwd`/repo/
BENCHMARK_DIR=${REPO_DIR}/ldbc_snb_interactive_impls_age/age

echo "=============================================================="
echo "Copy interactive implement repository"
echo "=============================================================="
rm -rf ${REPO_DIR}/ldbc_snb_interactive_impls_age
cp -r ${REPO_DIR}/ldbc_snb_interactive_impls-1.0.0 ${REPO_DIR}/ldbc_snb_interactive_impls_age
cp ./age-interactive/load_data_container.sh ${BENCHMARK_DIR}/scripts/load_data_container.sh
cp ./age-interactive/load_csv.sql.base ${BENCHMARK_DIR}/scripts/load_csv.sql.base

cd ${BENCHMARK_DIR}
./scripts/install-dependencies.sh
pyenv local ${PYENV_NAME}
pip3 install --progress-bar off psycopg
pyenv local system

echo "=============================================================="
echo "Copy environment files"
echo "=============================================================="
cp scripts/vars.sh scripts/vars.sh.base
cp .env .env.base
cp config/postgresql.conf config/postgresql.conf.base
cp docker-compose.yml docker-compose.yml.base
rm scripts/vars.sh
rm .env
rm config/postgresql.conf
rm docker-compose.yml

echo "=============================================================="
echo "Make baseline environment files"
echo "=============================================================="
sed -i "s/\`pwd\`\/scratch\/data/(POSTGRES_DATA_DIR)/g" ${BENCHMARK_DIR}/scripts/vars.sh.base

sed -i "s/.\/config\/postgresql.conf/(POSTGRES_CUSTOM_CONFIGURATION)/g" ${BENCHMARK_DIR}/.env.base
sed -i "s/.\/scratch\/data/(POSTGRES_DATA_DIR)/g" ${BENCHMARK_DIR}/.env.base
sed -i "s/\/ldbc-data\/social_network-csv_merge_foreign-sf1/(POSTGRES_CSV_DIR)/g" ${BENCHMARK_DIR}/.env.base
sed -i "s/postgres:14.2/(DOCKER_IMAGE_NAME)/g" ${BENCHMARK_DIR}/.env.base

sed -i "s/4GB/(shared_buffers)/g" ${BENCHMARK_DIR}/config/postgresql.conf.base
sed -i "s/12GB/(effective_cache_size)/g" ${BENCHMARK_DIR}/config/postgresql.conf.base
sed -i "s/16MB/(wal_buffers)/g" ${BENCHMARK_DIR}/config/postgresql.conf.base
sed -i "s/6990kB/(work_mem)/g" ${BENCHMARK_DIR}/config/postgresql.conf.base
sed -i "s/en_US.utf8/C/g" ${BENCHMARK_DIR}/config/postgresql.conf.base

sed -i "5 a\    shm_size: (shm_size)" docker-compose.yml.base
sed -i "10 a\      - type: bind" docker-compose.yml.base
sed -i '11 a\        source: ${POSTGRES_SCRIPTS_DIR}/load_data_container.sh' docker-compose.yml.base
sed -i "12 a\        target: /var/lib/postgresql/load_data_container.sh" docker-compose.yml.base
sed -i "13 a\      - type: bind" docker-compose.yml.base
sed -i '14 a\        source: ${POSTGRES_SCRIPTS_DIR}/load_csv.sql.base' docker-compose.yml.base
sed -i "15 a\        target: /var/lib/postgresql/load_csv.sql.base" docker-compose.yml.base
sed -i "13 a\      - type: bind" docker-compose.yml.base
sed -i '14 a\        source: ${AGE_CSV_DIR}' docker-compose.yml.base
sed -i "15 a\        target: /var/lib/postgresql/csv_data" docker-compose.yml.base

sed -i "s@# - type: bind@- type: bind@g" docker-compose.yml.base
sed -i "s@#   source: \${POSTGRES_DATA_DIR}@  source: (POSTGRES_DATA_DIR)@g" docker-compose.yml.base
sed -i "s@#   target: /var/lib/postgresql/data@  target: /var/lib/postgresql/data@g" docker-compose.yml.base
sed -i "s@snb-interactive-postgres@snb-interactive-age@g" docker-compose.yml.base
