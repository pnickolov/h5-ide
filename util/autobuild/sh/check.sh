#!/bin/sh

DIR=$(cd "$(dirname "$0")"; pwd)
cd $DIR

exec >> log/check.log 2>&1

NEEDBUILD=`cat etc/needbuild`

if [ "${NEEDBUILD}" == "1" ]
then
    echo "[`date`] need build"
    ps -ef | grep "build.sh" | grep -v grep | awk '{printf $2}' | xargs kill -9
    ./build.sh &
    echo 0 > etc/needbuild
else
    echo "[`date`] no need build"
fi


