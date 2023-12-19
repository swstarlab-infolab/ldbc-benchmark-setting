#!/bin/bash

# SF=100
# thread_count=1
# warmup=200
# operation_count=1000
# TCR=1

RESULT_DIR=result_age_sf1_tcr1_tc1_oc1

PYENV_NAME=ldbc_datagen_tools
HOME_DIR=`pwd`
SCRIPT_DIR=`pwd`/age-interactive/
REPO_DIR=`pwd`/repo/
BENCHMARK_DIR=${REPO_DIR}/ldbc_snb_interactive_impls_age/age

cd ${BENCHMARK_DIR}
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
echo "=============================================================="
echo "Run benchmark"
echo "=============================================================="
if [ $1 = "validate" ]; then
    chmod +x driver/create-validation-parameters.sh
    chmod +x driver/validate.sh
    driver/create-validation-parameters.sh
    driver/validate.sh
fi

if [ $1 = "benchmark" ]; then
    chmod +x driver/benchmark.sh
    driver/benchmark.sh
    mkdir -p ${HOME_DIR}/results/interactive/${RESULT_DIR}
    mv results/* ${HOME_DIR}/results/interactive/${RESULT_DIR}
    cp config/postgresql.conf ${HOME_DIR}/results/interactive/${RESULT_DIR}
fi