#!/bin/sh

DIR=$(cd "$(dirname "$0")"; pwd)
cd $DIR

FILENAME="ide-alpha.tar.gz"

cd ../../src

echo "start make..."
grunt make_all
echo "make done"
echo

rm ${FILENAME} -rf
echo "start tar..."
tar czf ${FILENAME} *
echo "tar done."

echo "start transfer..."
scp ${FILENAME} root@211.98.26.7:/madeira/site/ide_h5
echo "transfer done."
echo
echo "ide on 26.7 will be updated after severial minutes."
echo
echo "remove ${FILENAME}"
rm ${FILENAME} -rf
echo
echo "all done. "
