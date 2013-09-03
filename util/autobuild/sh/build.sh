#!/bin/sh

DIR=$(cd "$(dirname "$0")"; pwd)
cd $DIR

exec >> log/build.log 2>&1

echo 
echo "########################################################################"
echo "## start sync develop code [ `date` ] ##################################"
echo 

#update develop brunch
cd /madeira/source/html5/ide
git checkout develop
git pull origin
echo
echo "=================================================="
git log -n 1
echo "=================================================="
echo 

#kill last grunt dev_all
ps -ef | grep "grunt dev_all" | grep -v grep | awk '{printf $2}' | xargs kill -9

#build
echo
echo "## start build [ `date` ] ##################################"
grunt dev_all



