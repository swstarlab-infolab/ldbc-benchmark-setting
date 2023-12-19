#!/bin/bash

PYENV_NAME=ldbc_datagen_tools
REPO_DIR=`pwd`/repo/
BENCHMARK_DIR=${REPO_DIR}/ldbc_snb_interactive_impls_pg_graph/pg-graph

echo "=============================================================="
echo "Copy interactive implement repository"
echo "=============================================================="
rm -rf ${REPO_DIR}/ldbc_snb_interactive_impls_pg_graph
cp -r ${REPO_DIR}/ldbc_snb_interactive_impls-1.0.0 ${REPO_DIR}/ldbc_snb_interactive_impls_pg_graph
cd ${BENCHMARK_DIR}
# chmod +x ./scripts/*.sh
# ./scripts/install-dependencies.sh
# pyenv local ${PYENV_NAME}
# pip3 install --progress-bar off psycopg
# pyenv local system

echo "=============================================================="
echo "Copy environment files"
echo "=============================================================="
cp scripts/vars.sh scripts/vars.sh.base
cp scripts/backup-database.sh scripts/backup-database.sh.base
cp scripts/restore-database.sh scripts/restore-database.sh.base
cp .env .env.base
cp config/postgresql.conf config/postgresql.conf.base
cp docker-compose.yml docker-compose.yml.base
rm scripts/vars.sh
rm scripts/backup-database.sh
rm scripts/restore-database.sh
rm .env
rm config/postgresql.conf
rm docker-compose.yml

echo "=============================================================="
echo "Make baseline environment files"
echo "=============================================================="
sed -i "s/\`pwd\`\/scratch\/data/(POSTGRES_DATA_DIR)/g" ${BENCHMARK_DIR}/scripts/vars.sh.base

sed -i "s/scratch/(POSTGRES_CONTAINER_ROOT)/g" ${BENCHMARK_DIR}/scripts/backup-database.sh.base
sed -i "s/scratch/(POSTGRES_CONTAINER_ROOT)/g" ${BENCHMARK_DIR}/scripts/restore-database.sh.base

sed -i "s/.\/config\/postgresql.conf/(POSTGRES_CUSTOM_CONFIGURATION)/g" ${BENCHMARK_DIR}/.env.base
sed -i "s/.\/scratch\/data/(POSTGRES_DATA_DIR)/g" ${BENCHMARK_DIR}/.env.base
sed -i "s/\/ldbc-data\/social_network-csv_merge_foreign-sf1/(POSTGRES_CSV_DIR)/g" ${BENCHMARK_DIR}/.env.base

sed -i "5 a\    shm_size: (shm_size)" docker-compose.yml.base
sed -i "s@# - type: bind@- type: bind@g" docker-compose.yml.base
sed -i "s@#   source: \${POSTGRES_DATA_DIR}@  source: (POSTGRES_DATA_DIR)@g" docker-compose.yml.base
sed -i "s@#   target: /var/lib/postgresql/data@  target: /var/lib/postgresql/data@g" docker-compose.yml.base