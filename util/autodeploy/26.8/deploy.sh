#!/bin/bash


function showusage(){
	echo "Usage: ./deploy.sh [N]"
	echo "	N: 0 #debug"
	echo "	N: 1 #release"
	exit 1	
}

if [ $# -ne 1 ]
then
	showusage
fi

if [ "$1" != "0" -a "$1" != "1" ]
then
	showusage
fi



DIR=$(cd "$(dirname "$0")"; pwd)
cd $DIR

PUBLISH_DIR=${DIR}/../../../publish
REMOTE_DIR="/visualops/site/s3"


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

echo "- Step 6 : generate version ---------------------------------------------------"
#generate version

if [ -f ${PUBLISH_DIR}/commit ]
then
    COMMIT=`cat ${PUBLISH_DIR}/commit | awk '{print $1}' | head -n 1 `
    AUTHOR=`cat ${PUBLISH_DIR}/commit | awk '{print $0}' | head -n 2 | tail -n 1 `
else
	echo "can not find ${PUBLISH_DIR}/commit, cancel"
	exit 1
fi

VER=`date "+%y%m%d.%H%M"`
if [ "${COMMIT}" != "" ]
then
    VER=${VER}"."${COMMIT:0:7}
fi
echo ">current version: "$VER
echo

echo "- Step 7 : change version in version.js ---------------------------------------------------"
#change version
cd ${PUBLISH_DIR}/lib

if [ "$1" == "0" ]
then
	#for debug
	sed -i "/  version = '/c   version = '${VER}'" version.js
else
	#for release
	sed -i "s/version=\".*\"/version=\"${VER}\"/g"  version.js
fi


echo "- Step 8 ---------------------------------------------------"
echo ">start transfer..."
echo ">start tar ${FILENAME}..."
cd ${PUBLISH_DIR}
tar czf ${FILENAME} *
echo ">tar done."
echo ""

echo "- Step 9 ---------------------------------------------------"
echo ">start transfer..."
scp ${FILENAME} root@211.98.26.8:${REMOTE_DIR}
echo ">transfer done."
echo ""

echo "- Step 10 ---------------------------------------------------"
echo ">ide had been uploaded to ${REMOTE_DIR} of 26.8, please run ./deploy.sh on 26.8 in /visualops/site/s3 "
echo ""

echo "----------------------------------------------------"
echo ">all done. "
echo ""
