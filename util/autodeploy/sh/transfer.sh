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



if [ $# -ne 1 ]
then
    echo "./transfer.sh SERVER_ID"
    echo "eg: ./transfer.sh 1"
    exit -1
fi

SERVER_ID=$1

if [ ${SERVER_ID} -ne 1 -a ${SERVER_ID} -ne 2 ]
then
    echo "SERVER_ID only support 1 or 2, quit"
    exit -1
fi


CUR_DIR=$(cd "$(dirname "$0")"; pwd)
cd $CUR_DIR

LOCAL_DIR="/opt/release/live/ide_h5"
REMOTE_DIR="/madeira/site/temp"

TGT_FILENAME="ide.tar.gz"
FILENAME1="ide-1.tar.gz"
FILENAME2="ide-2.tar.gz"
REMOTE_IP1="ec2-54-211-46-205.compute-1.amazonaws.com"
REMOTE_IP2="ec2-54-226-20-208.compute-1.amazonaws.com"

PEM_DIR="/opt/backup/hg/mainline/Madeira/keypair/live"

if [ ! -d ${CUR_DIR}/log ]
then
    mkdir -p ${CUR_DIR}/log
fi

if [ ! -d ${LOCAL_DIR}/bak ]
then
    mkdir -p ${LOCAL_DIR}/bak
fi


###########################################################

function transfer_to_server1 () {

    FILENAME=${FILENAME1}
    REMOTE_IP=${REMOTE_IP1}

    echo ">test tar ${FILENAME}..."
    tar tzf ${LOCAL_DIR}/${FILENAME} > /dev/null
    if [ $? -ne 0 ]
    then
        echo "tar file not correct,cancel"
        echo
        exit -1
    fi

    exec >> ${CUR_DIR}/log/transfer1.log 2>&1

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
    scp -i ${PEM_DIR}/beta.pem ${LOCAL_DIR}/${FILENAME} ec2-user@${REMOTE_IP}:${REMOTE_DIR}/${TGT_FILENAME}
    if [ $? -ne 0 ]
    then
        echo ">transfer failed,cancel"
        exit -1
    else
        echo ">transfer done."

        VER=`date "+%y%m%d.%H%M"`
        echo "backup ${LOCAL_DIR}/${FILENAME} to ${LOCAL_DIR}/bak/${VER}.${FILENAME}"
        #rename to ide-2.tar.gz
        if [ -f ${LOCAL_DIR}/${FILENAME2} ]
        then
            echo "remove old ${LOCAL_DIR}/${FILENAME2}"
            rm -rf ${LOCAL_DIR}/${FILENAME2}
        fi
        mv ${LOCAL_DIR}/${FILENAME} ${LOCAL_DIR}/${FILENAME2}
        if [ $? -eq 0 ]
        then
            echo ">succeed"
        else
            echo ">failed,just rename ${LOCAL_DIR}/${FILENAME} to ${LOCAL_DIR}/${FILENAME2}"
        fi


    fi
}


function transfer_to_server2 () {

    FILENAME=${FILENAME2}
    REMOTE_IP=${REMOTE_IP2}

    echo ">test tar ${FILENAME}..."
    tar tzf ${LOCAL_DIR}/${FILENAME} > /dev/null
    if [ $? -ne 0 ]
    then
        echo "tar file not correct,cancel"
        echo
        exit -1
    fi

    exec >> ${CUR_DIR}/log/transfer2.log 2>&1

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
    scp -i ${PEM_DIR}/beta.pem ${LOCAL_DIR}/${FILENAME} ec2-user@${REMOTE_IP}:${REMOTE_DIR}/${TGT_FILENAME}
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
}


###########################################################
#main
###########################################################


if [ ${SERVER_ID} -eq 1 ]
then
    if [ -f ${LOCAL_DIR}/${FILENAME1} ]
    then
        transfer_to_server1
    else
        exit -1
    fi
else
    if [ -f ${LOCAL_DIR}/${FILENAME2} ]
    then
        transfer_to_server2
    else
        exit -1
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