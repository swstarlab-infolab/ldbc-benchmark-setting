#!/bin/bash

RESULT_DIR=result_agensgraph_readwrite_sf100

PYENV_NAME=ldbc_datagen_tools
HOME_DIR=`pwd`
SCRIPT_DIR=`pwd`/agensgraph-interactive/
REPO_DIR=`pwd`/repo/
BENCHMARK_DIR=${REPO_DIR}/ldbc_snb_interactive_impls_agensgraph/agensgraph

echo "=============================================================="
echo "Setting experiment setting"
echo "=============================================================="
cp ${SCRIPT_DIR}/driver/benchmark.properties.base ${BENCHMARK_DIR}/driver/benchmark.properties
cp ${SCRIPT_DIR}/driver/create-validation-parameters.properties.base ${BENCHMARK_DIR}/driver/create-validation-parameters.properties
cp ${SCRIPT_DIR}/driver/validate.properties.base ${BENCHMARK_DIR}/driver/validate.properties

cd ${BENCHMARK_DIR}
rm validation_params-failed-actual.json
rm validation_params-failed-expected.json
rm validation_params.csv
rm tcr.log

pyenv local ${PYENV_NAME}
echo "=============================================================="
echo "Run benchmark"
echo "=============================================================="
if [ $1 = "validate" ]; then
    chmod +x driver/*.sh
    driver/create-validation-parameters.sh
    driver/validate.sh
fi

if [ $1 = "benchmark" ]; then
    chmod +x driver/*.sh
    driver/benchmark.sh
    mkdir -p ${HOME_DIR}/results/interactive/${RESULT_DIR}
    mv results/* ${HOME_DIR}/results/interactive/${RESULT_DIR}
    cp ${SCRIPT_DIR}/config/postgresql.conf ${HOME_DIR}/results/interactive/${RESULT_DIR}
fi

if [ $1 = "tcr" ]; then
    chmod +x driver/*.sh
    chmod +x ../driver/determine-best-tcr-common.sh
    driver/determine-best-tcr.sh
fi
pyenv local system