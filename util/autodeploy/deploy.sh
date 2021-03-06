#!/bin/bash

DIR=$(cd "$(dirname "$0")"; pwd)
cd $DIR

PUBLISH_DIR=${DIR}/../../publish
REMOTE_DIR="/madeira/site/temp"


FILENAME="ide.tar.gz"


echo "- Step 1 ---------------------------------------------------"
echo ">remove old publish..."
if [ -d ${PUBLISH_DIR} ]
then
	rm -rf ${PUBLISH_DIR}
	sleep 4
fi
echo ""

echo "- Step 2 ---------------------------------------------------"
echo ">start make deploy..."
grunt deploy
echo ">make deploy done"
echo ""

echo "- Step 3 ---------------------------------------------------"
echo ">check ${PUBLISH_DIR}"
if [ ! -d ${PUBLISH_DIR} ]
then
    echo ">publish failed,quit"
    exit -1
fi
echo

echo "- Step 4 ---------------------------------------------------"
COMMIT=`git log -n 1 | grep commit | awk '{print $2}' `
AUTHOR=`git config --list | grep "^user.name" | awk  'BEGIN{FS="="}{print $2}'`
echo ">generate commit id: ${COMMIT}"
echo -e "${COMMIT}\n${AUTHOR}" > ${PUBLISH_DIR}/commit
echo ""

echo "- Step 5 ---------------------------------------------------"
cd ${PUBLISH_DIR}
if [ -f ${FILENAME} ]
then
	echo "remove old ${FILENAME}"
	rm ${FILENAME} -rf
	sleep 1
fi
echo ">start tar ${FILENAME}..."
tar czf ${FILENAME} *
echo ">tar done."
echo ""

echo "- Step 6 ---------------------------------------------------"
echo ">start transfer..."
scp ${FILENAME} root@211.98.26.7:${REMOTE_DIR}
echo ">transfer done."
echo ""

echo "- Step 7 ---------------------------------------------------"
echo ">ide had been uploaded to ${REMOTE_DIR} of 26.7, it will be transfered to /madeira/site/ide_h5 after severial minutes."
echo ""

echo "----------------------------------------------------"
echo ">all done. "
echo ""
