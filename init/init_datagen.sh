#!/bin/bash

PYENV_NAME=ldbc_datagen_tools
REPO_DIR=`pwd`/repo/

echo "=============================================================="
echo "Cloning hadoop datagen repository"
echo "=============================================================="
git -C ${REPO_DIR} clone git@github.com:Kalogon/ldbc_snb_datagen_hadoop-0.3.6.git
cd ${REPO_DIR}/ldbc_snb_datagen_hadoop-0.3.6

echo "=============================================================="
echo "Install hadoop"
echo "=============================================================="
wget http://archive.apache.org/dist/hadoop/core/hadoop-3.2.1/hadoop-3.2.1.tar.gz | tar xf -C ~/