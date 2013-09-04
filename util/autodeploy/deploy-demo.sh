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
scp -i ${DIR}/demo.pem ${FILENAME} ec2-user@54.238.48.118:/home/ec2-user/ide
echo "transfer done."
echo
echo "ide on demo will be updated after severial minutes."
echo
echo "remove ${FILENAME}"
rm ${FILENAME} -rf
echo
echo "all done. "
