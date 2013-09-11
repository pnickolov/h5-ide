#!/bin/sh

PUBLISH_DIR="/opt/release/live/ide_h5"

DIR=$(cd "$(dirname "$0")"; pwd)
cd $DIR

FILENAME="ide.tar.gz"

cd ../../publish


echo "- Step 1 ---------------------------------------------------"
echo ">check old file..."
if [ -f publish/${FILENAME} ]
then
	echo "remove ${FILENAME}"
	rm publish/${FILENAME} -rf
fi
echo ""

echo "- Step 2 ---------------------------------------------------"
echo ">start make deploy..."
grunt deploy
echo ">make deploy done"
echo ""
echo "- Step 3 ---------------------------------------------------"
COMMIT=`git log -n 1 | grep commit | awk '{print $2}' `
echo ">generate commit id: ${COMMIT}"
echo ${COMMIT} > ../publish/commit
echo ""

echo "- Step 4 ---------------------------------------------------"
rm ${FILENAME} -rf
echo ">start tar ${FILENAME}..."
tar czf ${FILENAME} *
echo ">tar done."
echo ""

echo "- Step 5 ---------------------------------------------------"
echo ">start transfer..."
scp ${FILENAME} root@211.98.26.6:${PUBLISH_DIR}
echo ">transfer done."
echo ""

echo "- Step 6 ---------------------------------------------------"
echo ">ide on 26.6 will be transfer to h5 live after severial minutes."
echo ""

echo "----------------------------------------------------"
echo ">all done. "
echo ""
