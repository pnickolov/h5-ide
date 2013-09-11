#!/bin/sh


BASE_DIR="/madeira/site"

FILENAME="ide.tar.gz"

VER=`date "+%y%m%d.%H%M"`


SRC_DIR=${BASE_DIR}/temp       #source
TGT_DIR=${BASE_DIR}/ide_h5     #target
BAK_DIR=${BASE_DIR}/bak #backup


CUR_DIR=$(cd "$(dirname "$0")"; pwd)
cd $CUR_DIR

#############################################
function create_dir (){

    DIRNAME=$1
    RECREATE=$2   #0 false  1 true

    #if RECREATE is 1 then remove old dir first
    if [ ${RECREATE} -eq 1 -a -d ${DIRNAME} ]
    then
        echo ">remove old dir ${DIRNAME}"
        rm -rf ${DIRNAME}
        if [ $? -ne 0 ]
        then
            echo ">failed,cancel"
            exit -1
        fi
    fi

    #create target dir
    if [ ${RECREATE} -eq 1 ]
    then
        echo ">create new dir ${DIRNAME}"
    else
        echo ">check dir ${DIRNAME}"
    fi

    mkdir -p ${DIRNAME}
    sleep 1

    #verify target dir
    if [ -d ${DIRNAME} ]
    then
        echo ">succeed"
        echo
    else
        echo ">failed,cancel"
        exit -1
    fi

}

#############################################



#exec > ${CUR_DIR}/log/check.log 2>&1

START_TIME=`date "+%y/%m/%d %H:%M"`

#create dir
create_dir ${CUR_DIR}/log 0
create_dir ${BASE_DIR} 0
create_dir ${SRC_DIR} 0
create_dir ${TGT_DIR} 0
create_dir ${BAK_DIR} 0


echo "- Step 1 : check ${SRC_DIR}/${FILENAME} ---------------------------------------------------"
if [ -f ${SRC_DIR}/${FILENAME} ]
then

    exec > ${CUR_DIR}/log/check.log 2>&1


    echo ""
    echo "==========================================================="
    echo ""
    echo " Start Time: ${START_TIME}"
    echo ""
    echo "==========================================================="


    echo "- Step 1 : check ${SRC_DIR}/${FILENAME} ---------------------------------------------------"

    echo ">found ${SRC_DIR}/${FILENAME},now will update ide"
    echo

    cd ${SRC_DIR}

    echo "- Step 2 : test ${SRC_DIR}/${FILENAME} ---------------------------------------------------"
    #test tar file
    tar tzf ${FILENAME} >/dev/null
    if [ $? -eq 0 ]
    then
    #file is correct
        echo "> ${SRC_DIR}/${FILENAME} is correct"
        echo

        echo "- Step 3 : create new dir ${TGT_DIR}.tmp ---------------------------------------------------"
        #create new tmp dir
        create_dir ${TGT_DIR}.tmp 1

        #mv tar file to tmp dir
        echo "- Step 4 : move ${SRC_DIR}/${FILENAME} to ${TGT_DIR}.tmp ---------------------------------------------------"
        mv ${SRC_DIR}/${FILENAME} ${TGT_DIR}.tmp
        if [ ! -f ${TGT_DIR}.tmp/${FILENAME} ]
        then
            echo "failed,cancel!"
            exit -1
        else
            echo ">succeed"
            echo ""
        fi

        cd ${TGT_DIR}.tmp
        echo "- Step 5 : untar ${TGT_DIR}.tmp/${FILENAME} ---------------------------------------------------"
        tar xzf ${TGT_DIR}.tmp/${FILENAME}
        if [ $? -eq 0 ]
        then
            echo ">succeed"
            chown InstantForge:InstantForge ${TGT_DIR}.tmp -R
            chmod 755 ${TGT_DIR}.tmp -R
            echo
        else
            echo ">untar failed,cancel"
            exit -1
        fi

        echo "- Step 6 : generate version ---------------------------------------------------"
        #generate version
        COMMIT="" #default
        if [ -f ${TGT_DIR}.tmp/commit ]
        then
            COMMIT=`cat ${TGT_DIR}.tmp/commit | awk '{print $1}' | head -n 1 `
        fi

        if [ "${COMMIT}" != "" ]
        then
            VER=${VER}"."${COMMIT:0:7}
        fi


        echo ">current version: "$VER
        echo


        echo "- Step 7 : change version in version.js ---------------------------------------------------"
        #change version
        cd ${TGT_DIR}.tmp/lib
        sed -i "/version=\"/cvar version=version||{};\!function(){version=\"${VER}\"}();" version.js
        echo ">version after change:"
        echo "--------------------------------------------------------------"
        cat version.js
        echo
        echo "--------------------------------------------------------------"
        echo

        echo "- Step 8 : backup ${TGT_DIR}.tmp/${FILENAME} to ${BAK_DIR}/${VER}-${FILENAME} -------------------------------"
        #backup tar
        mv ${TGT_DIR}.tmp/${FILENAME} ${BAK_DIR}/${VER}-${FILENAME}
        if [ $? -eq 0 ]
        then
            echo ">backup succeed!"
        else
            echo ">backup failed,cancel"
            exit -1
        fi
        echo


        #replace new version
        echo "- Step 9 : check old ${TGT_DIR}.bak ---------------------------------------------------"
        if [ -d ${TGT_DIR}.bak ]
        then
            echo ">remove old ${TGT_DIR}.bak "
            rm -rf ${TGT_DIR}.bak
            sleep 2
            echo
        fi

        if [ -d ${TGT_DIR}.bak ]
        then
            echo ">remove old ${TGT_DIR}.bak failed,cancel!"
            exit -1
        else
            echo "- Step 10 : move ${TGT_DIR} to ${TGT_DIR}.bak ---------------------------------------------------"
            mv ${TGT_DIR} ${TGT_DIR}.bak
            sleep 1
            if [ $? -eq 0 ]
            then
                echo ">succeed"
                echo
            else
                echo ">failed,cancel"
                exit -1
            fi

            echo "- Step 11 : move ${TGT_DIR}.tmp to ${TGT_DIR} ---------------------------------------------------"
            mv ${TGT_DIR}.tmp ${TGT_DIR}
            sleep 1
            if [ $? -eq 0 ]
            then
                echo ">succeed"
                echo
            else
                echo ">failed,quit!"
                exit -1
            fi
        fi

        echo "-----------------------------------"
        echo " all done."

        echo
        echo "============================================================"
        echo "== Start Time: ${START_TIME}"
        echo "== End Time:   `date "+%y/%m/%d %H:%M"`"
        echo "============================================================"
        echo

    else
        echo ">tar file not correct,quit"
    fi
#else
   # echo "[`date`] no need updated"
fi

