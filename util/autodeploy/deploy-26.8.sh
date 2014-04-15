#!/bin/bash

DIR=$(cd "$(dirname "$0")"; pwd)
cd $DIR

FILENAME="ide.tar.gz"

cd ${DIR}/../../src

echo "now will deploy develop version to 26.8"
echo "start make(grunt debug)..."
grunt debug
echo "make done"
echo

cd ${DIR}/../../debug

COMMIT=`git log -n 1 | grep commit | awk '{print $2}' `
AUTHOR=`git config --list | grep "user.name" | awk  'BEGIN{FS="="}{print $2}'`
echo ">generate commit id: ${COMMIT}"
echo -e "${COMMIT:0:3}.dev\n${AUTHOR}" > commit
echo ""


rm ${FILENAME} -rf
echo "start tar..."
tar czf ${FILENAME} *
echo "tar done."

echo "start transfer..."
scp ${FILENAME} root@211.98.26.8:/visualops/site/temp
echo "transfer done."
echo
echo "${FILENAME} had been uploaded to /visualops/site/temp of 26.8"
echo "ide on 26.8 will be updated after severial minutes."
echo
echo "remove ${FILENAME}"
rm ${FILENAME} -rf
rm commit
echo
echo "all done. "