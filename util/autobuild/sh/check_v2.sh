#!/bin/sh

MADEIRA="/madeira"
FILENAME="ide-alpha.tar.gz"

DIR=$(cd "$(dirname "$0")"; pwd)

cd ${MADEIRA}/site/ide_h5/

exec >> ${DIR}/log/check_v2.log 2>&1

if [ -f ${FILENAME} ]
then
    tar xzf ${FILENAME}
    if [ $? -eq 0 ]
    then
    	chown InstantForge:InstantForge * -R
    	if [ ! -d bak ]
        then
            mkdir -p bak
        fi
        mv ${FILENAME} bak/

        #change version
        cd lib
        VER=`date "+%y%m%d.%H%M"`
        sed -i "/  version = '/c   version = '${VER}'" version.js


        echo "[`date`] updated succeed"
    else
        echo "[`date`] updated failed"
    fi
#else
   # echo "[`date`] no need updated"
fi


