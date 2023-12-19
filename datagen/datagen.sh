#!/bin/bash

HOME_DIR=`pwd`
SCRIPT_DIR=`pwd`/datagen/
REPO_DIR=`pwd`/repo/
DATAGEN_DIR=${REPO_DIR}/ldbc_snb_datagen_hadoop-0.3.6


echo "=============================================================="
echo "Setting datagen setting"
echo "=============================================================="
cp -pr ${SCRIPT_DIR}/driver/params.ini ${DATAGEN_DIR}/params.ini
cp -pr ${SCRIPT_DIR}/driver/run.sh ${DATAGEN_DIR}/run.sh


cd ${DATAGEN_DIR}
echo "=============================================================="
echo "Run datagen"
echo "=============================================================="
./run.sh