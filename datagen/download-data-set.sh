#!/bin/bash

set -eu

if [ "$#" -ne 1 ]; then
  echo "Usage: $0 DATA_SET_URL"
  exit 1
fi

DATA_SET_URL=${1}

echo "Preparing to download ${DATA_SET_URL}"
while [[ $(curl --silent --head ${DATA_SET_URL} | grep 'HTTP/1.1 409 Conflict') ]]; do
    echo "Data set is not staged, attempting to stage..."
    STAGE_URL=$(curl --silent ${DATA_SET_URL} | grep -Eo 'https:\\/\\/repository.surfsara.nl\\/api\\/objects\\/cwi\\/[A-Za-z_-]+\\/stage\\/[0-9]+' | sed 's#\\##g')
    curl ${STAGE_URL} --data-raw 'share-token='
    echo "Staging initiated through ${STAGE_URL}"
    echo "Wait for 30 seconds"
    sleep 30
done

echo "Downloading data set"
curl --silent --fail ${DATA_SET_URL} | tar -xv --use-compress-program=unzstd