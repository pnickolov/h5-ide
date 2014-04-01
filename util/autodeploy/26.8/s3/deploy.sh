#!/bin/bash
#/visualops/site/s3/deploy.sh
#usage: 
# cd /visualops/site/s3
# ./deploy.sh


DIR=$(cd "$(dirname "$0")"; pwd)
cd $DIR



FILENAME=ide.tar.gz
TARGETDIR=s3://madeiradeploy/2014-03-28/
CHKSUMFILE=checksum
SYNC=1 #1. can sync  2. can not sync

echo
echo "=============================================="
echo "1.Check file"
if [ ! -f ./${FILENAME} ]
then
	echo ">${FILENAME} not found,cancel sync"
	exit 1
fi


echo "=============================================="
echo "2.Check checksum change"
NEWCHKSUM=`md5sum ide.tar.gz | awk '{printf $1}'`
if [ -f ${CHKSUMFILE} ]
then
	OLDCHECKSUM=`head -n 1 checksum`
	echo ">Found checksum, old checksum is ${OLDCHECKSUM}"
	echo ">new checksum is ${NEWCHKSUM}"
	echo "'${NEWCHKSUM}' == '${OLDCHECKSUM}'" 
	if [ "${NEWCHKSUM}" == "${OLDCHECKSUM}" ]
	then
		SYNC=0
		echo ">No change,skip sync"
		exit 1
	else
		echo ">Checksum changed, need sync"
	fi
elif [ "${NEWCHKSUM}" == "" ]
then
	SYNC=0
	echo ">Not valid checksum,cancel sync"
fi


echo "=============================================="
echo "3.Check checksum valid"
if [ `expr length ${NEWCHKSUM}` -eq 32 ]
then
	echo ">Checksum valid, can sync"
else
	echo ">First time, need sync"
fi


echo "=============================================="
echo "3.Start sync ${FILENAME} to S3..."
s3cmd sync ./${FILENAME} ${TARGETDIR}
if [ $? -eq 0 ]
then
	echo ">Succeed."
	echo ${NEWCHKSUM} > ${CHKSUMFILE}
else
	echo ">Failed."
fi

echo 
echo "Done, please change checksum in app, new checksum is ${NEWCHKSUM}"
echo
