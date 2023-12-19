#!/bin/bash

PYENV_NAME=ldbc_datagen_tools
REPO_DIR=`pwd`/repo/
BENCHMARK_DIR=${REPO_DIR}/ldbc_snb_interactive_impls_neo4j/cypher
NEO4J_VERSION=${NEO4J_VERSION:-4.4.1}

echo "=============================================================="
echo "Copy interactive implement repository"
echo "=============================================================="
rm -rf ${REPO_DIR}/ldbc_snb_interactive_impls_neo4j
cp -r ${REPO_DIR}/ldbc_snb_interactive_impls-1.0.0 ${REPO_DIR}/ldbc_snb_interactive_impls_neo4j
cd ${BENCHMARK_DIR}
chmod +x ./scripts/*.sh
./scripts/install-dependencies.sh
pyenv local ${PYENV_NAME}
NEO4J_PACKAGE_VERSION=$(sed -E 's/[^.0-9]//g' <<< ${NEO4J_VERSION})
pip3 install neo4j==${NEO4J_PACKAGE_VERSION} python-dateutil
pyenv local system

echo "=============================================================="
echo "Copy environment files"
echo "=============================================================="
cp scripts/vars.sh scripts/vars.sh.base
cp scripts/backup-database.sh scripts/backup-database.sh.base
cp scripts/restore-database.sh scripts/restore-database.sh.base
rm scripts/vars.sh
rm scripts/backup-database.sh
rm scripts/restore-database.sh


echo "=============================================================="
echo "Make baseline environment files"
echo "=============================================================="
sed -i "s/\`pwd\`\/scratch/(NEO4J_CONTAINER_ROOT)/g" ${BENCHMARK_DIR}/scripts/vars.sh.base
sed -i 's/NEO4J_ENV_VARS=""/NEO4J_ENV_VARS=(NEO4J_ENV_VARS)/g' ${BENCHMARK_DIR}/scripts/vars.sh.base
sed -i "s/scratch/(NEO4J_CONTAINER_ROOT)/g" ${BENCHMARK_DIR}/scripts/backup-database.sh.base
sed -i "s/scratch/(NEO4J_CONTAINER_ROOT)/g" ${BENCHMARK_DIR}/scripts/restore-database.sh.base