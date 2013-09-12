#!/bin/sh

DIR=$(cd "$(dirname "$0")"; pwd)
cd $DIR

FILENAME="ide.tar.gz"

cd ../../src

echo "now will deploy develop version to 26.7"
echo "start make..."
grunt make_all
echo "make done"
echo

COMMIT=`git log -n 1 | grep commit | awk '{print $2}' `
echo ">generate commit id: ${COMMIT}"
echo ${COMMIT} > commit
echo ""


rm ${FILENAME} -rf
echo "start tar..."
tar czf ${FILENAME} *
echo "tar done."

echo "start transfer..."
scp ${FILENAME} root@211.98.26.7:/madeira/site/temp
echo "transfer done."
echo
echo "${FILENAME} had been uploaded to /madeira/site/temp of 26.7"
echo "ide on 26.7 will be updated after severial minutes."
echo
echo "remove ${FILENAME}"
rm ${FILENAME} -rf
rm commit
echo
echo "all done. "
