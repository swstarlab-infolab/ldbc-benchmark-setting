#!/bin/bash

REPO_DIR=`pwd`/repo/
PYENV_NAME=ldbc_bi

echo "=============================================================="
echo "Clonging bi implement repository"
echo "=============================================================="
rm -rf ${REPO_DIR}/ldbc_snb_bi-1.0.2
git -C ${REPO_DIR} clone git@github.com:Kalogon/ldbc_snb_bi-1.0.2.git
cd ${REPO_DIR}/ldbc_snb_bi-1.0.2

echo "=============================================================="
echo "Install paramgen dependencies"
echo "=============================================================="
pyenv local ${PYENV_NAME}
chmod +x scripts/*
chmod +x paramgen/scripts/*
chmod +x cypher/scripts/*
chmod +x umbra/scripts/*
chmod +x tigergraph/scripts/*
scripts/install-dependencies.sh
pyenv local system