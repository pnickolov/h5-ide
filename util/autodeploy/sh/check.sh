#!/bin/sh

MADEIRA="/madeira"
FILENAME="ide-alpha.tar.gz"

DIR=$(cd "$(dirname "$0")"; pwd)

cd $DIR

TGT_DIR=${MADEIRA}/site

exec >> ${DIR}/log/check.log 2>&1

if [ -f ide/${FILENAME} ]
then
    cd ide
    tar xzf ${FILENAME}
    if [ $? -eq 0 ]
    then
        rm -rf ${TGT_DIR}/ide_h5.bak
        mv ${TGT_DIR}/ide_h5 ${TGT_DIR}/ide_h5.bak
        mkdir ${TGT_DIR}/ide_h5
        mv * ${TGT_DIR}/ide_h5
        cd ${TGT_DIR}/ide_h5
        chown InstantForge:InstantForge * -R
        if [ ! -d bak ]
        then
            mkdir -p bak
        fi
        mv ${FILENAME} bak/
        echo "[`date`] updated succeed"
    else
        echo "[`date`] updated failed"
    fi
#else
   # echo "[`date`] no need updated"
fi
