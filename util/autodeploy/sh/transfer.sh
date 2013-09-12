#!/bin/sh
#############################
#
# /home/ec2-user/ide/transfer.sh
# this script need be run on 26.6
# transfer from 26.6 to h5 live
# (local)/opt/release/live/ide_h5/ide.tar.gz -> (remote)/madeira/site/temp
#
# add to crontab
# */1 * * * * su - root -c "/home/ec2-user/ide/transfer.sh > /dev/null 2>&1"
#############################

CUR_DIR=$(cd "$(dirname "$0")"; pwd)
cd $CUR_DIR

LOCAL_DIR="/opt/release/live/ide_h5"
REMOTE_DIR="/madeira/site/temp"
FILENAME="ide.tar.gz"
REMOTE_IP="ec2-54-211-46-205.compute-1.amazonaws.com"
PEM_DIR="/opt/backup/hg/mainline/Madeira/keypair/live"

if [ ! -d ${CUR_DIR}/log ]
then
    mkdir -p ${CUR_DIR}/log
fi

if [ ! -d ${LOCAL_DIR}/bak ]
then
    mkdir -p ${LOCAL_DIR}/bak
fi

echo ">test tar ${FILENAME}..."
tar tzf ${LOCAL_DIR}/${FILENAME} > /dev/null
if [ $? -ne 0 ]
then
    echo "tar file not correct,cancel"
    echo
    exit -1
fi

exec >> ${CUR_DIR}/log/transfer.log 2>&1

START_TIME=`date "+%y/%m/%d %H:%M"`
echo ""
echo "==========================================================="
echo ""
echo " Start Time: ${START_TIME}"
echo ""
echo "==========================================================="
echo
echo ">test tar file ${LOCAL_DIR}/${FILENAME} ok"
echo

echo ">start transfer..."
scp -i ${PEM_DIR}/beta.pem ${LOCAL_DIR}/${FILENAME} ec2-user@${REMOTE_IP}:${REMOTE_DIR}
if [ $? -ne 0 ]
then
    echo ">transfer failed,cancel"
    exit -1
else
    echo ">transfer done."

    VER=`date "+%y%m%d.%H%M"`
    echo "backup ${LOCAL_DIR}/${FILENAME} to ${LOCAL_DIR}/bak/${VER}.${FILENAME}"
    mv ${LOCAL_DIR}/${FILENAME} ${LOCAL_DIR}/bak/${VER}.${FILENAME}
    if [ $? -eq 0 ]
    then
        echo ">succeed"
    else
        echo ">failed,just rename ${LOCAL_DIR}/${FILENAME} to ${LOCAL_DIR}/bak/${VER}.${FILENAME}"
        mv ${LOCAL_DIR}/${FILENAME} ${LOCAL_DIR}/bak/${VER}.${FILENAME}
    fi


fi

echo ""
echo ">file ${LOCAL_DIR}/${FILENAME} had been transfered to ${REMOTE_IP}:${REMOTE_DIR}"
echo ">ide will be updated after several minutes"
echo ""

echo "----------------------------------------------------"
echo ">all done. "
echo ""
echo
echo "============================================================"
echo "== Start Time: ${START_TIME}"
echo "== End Time:   `date "+%y/%m/%d %H:%M"`"
echo "============================================================"
echo