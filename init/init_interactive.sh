#!/bin/bash

REPO_DIR=`pwd`/repo/
PYENV_NAME=ldbc_datagen_tools

echo "=============================================================="
echo "Clonging interactive implement repository"
echo "=============================================================="
rm -rf ${REPO_DIR}/ldbc_snb_interactive_impls-1.0.0
git -C ${REPO_DIR} clone git@github.com:Kalogon/ldbc_snb_interactive_impls-1.0.0.git
cd ${REPO_DIR}/ldbc_snb_interactive_impls-1.0.0

echo "=============================================================="
echo "Build repository"
echo "=============================================================="
chmod +x scripts/build.sh
scripts/build.sh
