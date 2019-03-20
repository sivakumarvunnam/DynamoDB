#!/bin/bash

# Downloads and install DynamoDB as a local install for linux distributions

TAR_URL=https://s3-sa-east-1.amazonaws.com/dynamodb-local-sao-paulo/dynamodb_local_latest.tar.gz
DEPLOY_DIR=/opt/dynamodb

# Make sure the directory exists
if [ ! -d ${DEPLOY_DIR} ]
then
    mkdir -p ${DEPLOY_DIR}
    if [ $? -ne 0 ]
    then
        (>&2 echo "Can't create deployment directory")
        exit 1
    fi
fi

archive=$(basename ${TAR_URL})

# Download package
echo "Downloading package.... Don't close this window."
wget $url -qO ${archive} ${TAR_URL} -q --show-progress

if [ $? -gt 1 ]
then
    (>&2 echo "Package download failed")
    rm -f ${archive}
    exit 1
fi

HERE=$(pwd)

echo
echo -n "Extracting archive: "
tar xfv ${archive} -C ${DEPLOY_DIR}
if [ $? -gt 1 ]
then
    (>&2 echo "extract failed")
    rm -f ${archive}
    exit 1
fi

rm -f ${archive}
cd ${DEPLOY_DIR}
if [ ! -d ${DEPLOY_DIR}/data ]
then
    mkdir ${DEPLOY_DIR}/data
    find ${DEPLOY_DIR}/ -type d -exec chmod 755 {} \;
    find ${DEPLOY_DIR}/ -type f -exec chmod 644 {} \;
    chmod -R g+w ${DEPLOY_DIR}/data
fi

# Check we have a dynamodb user
echo
echo "Ensure dynamodb user exists"
grep -q dynamodb /etc/passwd
if [ $? -ne 0 ]
then
    useradd dynamodb
fi

chown -R dynamodb.dynamodb ${DEPLOY_DIR}

echo "Setting up service..."
# Grab files from github
wget --progress=dot -qO /etc/systemd/system/dynamodb.service https://raw.githubusercontent.com/knowrick/DynamoDB/master/dynamodb.service

systemctl daemon-reload
