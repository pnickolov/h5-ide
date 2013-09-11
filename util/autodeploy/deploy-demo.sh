#!/bin/sh

DIR=$(cd "$(dirname "$0")"; pwd)
cd $DIR

FILENAME="ide.tar.gz"

echo "start deploy..."
##grunt deploy
echo "deploy done"
echo


cd ../../publish

##rm ${FILENAME} -rf
echo "start tar..."
##tar czf ${FILENAME} *
echo "tar done."

echo "start transfer..."
scp -i ${DIR}/demo.pem ${FILENAME} ec2-user@54.238.48.118:/madeira/site/temp
echo "transfer done."
echo
echo "ide on demo will be updated after severial minutes."
echo
echo "remove ${FILENAME}"
rm ${FILENAME} -rf
echo
echo "all done. "
