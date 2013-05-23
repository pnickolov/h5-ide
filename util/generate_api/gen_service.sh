#!/bin/sh
#*************************************************************************************
#* Filename     : gen_service.sh
#* Creator      : Jimmy Xu
#* Create date  : 2012/12/12
#* Description  : generate js service from python api ( scan -> resolve -> generate )
# ************************************************************************************
# (c)Copyright 2012 Madeiracloud  All Rights Reserved
# ************************************************************************************

#shell dir
SH_BASE_DIR=$(cd "$(dirname "$0")"; pwd)
cd ${SH_BASE_DIR}

#python base dir
SRC_BASE_DIR_=${SH_BASE_DIR}/"../../../api/Source/INiT/Instant/Forge/AppService"
#python source subidr
SRC_DIR=( "Handler" "Forge" "AWS")

#javascript service dir
#TGT_BASE_DIR=${SH_BASE_DIR}/"../../src/service"
TGT_BASE_DIR=${SH_BASE_DIR}/"out.tmp"

#template file dir
TMPL_BASE_DIR=${SH_BASE_DIR}/"template"

###########################################################
# function
###########################################################

#===================================================================
# Generate ?_service.coffee
#===================================================================
function fn_genereate_coffee() {

    _SRC_FILE=$1
    _TGT_DIR=$2
    _FILE=$3
    _ORIGIN=$4
    _API=$5
    #_PARAM=$4

    #resolve param
    idx=0
    m=1
    while [ $# -gt 0 ]
    do
        if [ $idx -ge 3 ]
        then
            _PARAM[$m]="$1"
            m=`expr $m + 1`
        fi
        shift
        idx=`expr ${idx} + 1`
    done

    echo "++++++++++++++++++++++++++++++++++++++++++++++++++++++++++"
    echo "SRC_FILE: ${_SRC_FILE}"
    echo -e "FILE  : ${_FILE} \nORIGIN: ${_ORIGIN} \nAPI   : ${_API} \nPARAM : ${#_PARAM[@]}"

    _TGT_FILE=${_FILE/Handler/}
    _TGT_FILE=${_TGT_FILE/.py/}
    _TGT_FILE=${_TGT_FILE,,}
    echo -e "TGT_DIR: ${_TGT_DIR} \nTGT_FILE: ${_TGT_FILE}"

    #------------------------------------------------------------------------
    #1.generate service.coffee
    sed -e ":a;N;$ s/@@service_name/${_TGT_FILE}_service>/g;ba" ${TMPL_BASE_DIR}/service.coffee.tmpl \
    | sed -e ":a;N;$ s/@@api_name/${_TGT_FILE}_service>/g;ba" \
    | sed -e ":a;N;$ s/@@vo_name/${_TGT_FILE}_vo/g;ba" \
    | sed -e ":a;N;$ s/@@parser_name/${_TGT_FILE}_parser>/g;ba" \
    | sed -e ":a;N;$ s/@@parser_fn/$parser{_TGT_FILE}Result>/g;ba" \
    > ${_TGT_DIR}/${_TGT_FILE}_service.coffee

    #2.generate parser.coffee
    sed -e ":a;N;$ s/@@service_name/${_TGT_FILE}_service>/g;ba" ${TMPL_BASE_DIR}/parser.coffee.tmpl \
    | sed -e ":a;N;$ s/@@api_name/${_TGT_FILE}_service>/g;ba" \
    | sed -e ":a;N;$ s/@@vo_name/${_TGT_FILE}_vo/g;ba" \
    | sed -e ":a;N;$ s/@@parser_name/${_TGT_FILE}_parser>/g;ba" \
    | sed -e ":a;N;$ s/@@parser_fn/$parser{_TGT_FILE}Result>/g;ba" \
    > ${_TGT_DIR}/${_TGT_FILE}_parser.coffee

    #3.generate vo.coffee
    sed -e ":a;N;$ s/@@service_name/${_TGT_FILE}_service>/g;ba" ${TMPL_BASE_DIR}/vo.coffee.tmpl \
    | sed -e ":a;N;$ s/@@api_name/${_TGT_FILE}_service>/g;ba" \
    | sed -e ":a;N;$ s/@@vo_name/${_TGT_FILE}_vo/g;ba" \
    | sed -e ":a;N;$ s/@@parser_name/${_TGT_FILE}_parser>/g;ba" \
    | sed -e ":a;N;$ s/@@parser_fn/$parser{_TGT_FILE}Result>/g;ba" \
    > ${_TGT_DIR}/${_TGT_FILE}_vo.coffee

    for (( n = 1 ; n <= ${#_PARAM[@]} ; n++ ))
    do
        echo "   param  : "${_PARAM[$n]}
    done
    echo "++++++++++++++++++++++++++++++++++++++++++++++++++++++++++"

}


#===================================================================
# Resolve api and param in python file [ invoke by fn_scan_handler_forge() and fn_scan_aws() ]
#===================================================================
function fn_resolve_api() {
#common function

    CUR_DIR=$1
    CUR_FILE=$2
    TGT_DIR=$3

    echo
    echo "#......................................................."
    echo "# SRC_FILE: "${CUR_DIR}/${CUR_FILE}
    echo "# TGT_DIR : "${TGT_DIR}
    echo "#......................................................."

    API_NAME=()
    API_PARAM=()

    #Resolve all api and params in ${CUR_DIR}/${CUR_FILE}
    CMD=`cat ${CUR_DIR}/${CUR_FILE} | grep "def " | grep -v "def _" | grep -v "def test" | grep -v "#def" | grep -v "params_" | \
        awk 'BEGIN{FS="[ (:)]"}{printf "ORIGIN[%d]=\"%s\";API_NAME[%d]=\"%s\";",NR,$0,NR,$2; for ( x=4; x<=NF-2; x++){ gsub(",","",$x); printf "API_PARAM_%s[%s]=\"%s\";",NR,x-3,$x};printf "\n" }' `
    #Generate API_NAME and API_PARAM
    eval ${CMD}

    #loop by API_NAME
    for (( j = 1 ; j <= ${#API_NAME[@]} ; j++ ))
    do
        echo

        CUR_ORIGIN=${ORIGIN[$j]}
        #echo "origin:"${CUR_ORIGIN}

        CUR_API=${API_NAME[$j]}
        #echo "api   : "${CUR_API}

        P_NUM='echo ${#API_PARAM_'${j}'[@]}'
        P_NUM=`eval ${P_NUM}`

        CUR_PARAM=()
        for (( k = 1 ; k <= ${P_NUM} ; k++ ))
        do
            TMP='${API_PARAM_'${j}'[$k]}'
            CUR_PARAM[$k]=`eval "echo $TMP"`
            #echo "    param> "${CUR_PARAM[$k]}
        done

        #echo "CUR_PARAM: "${#CUR_PARAM[@]}

        fn_genereate_coffee "${CUR_DIR}/${CUR_FILE}" "${TGT_DIR}" "${CUR_FILE}" "${CUR_ORIGIN}" "${CUR_API}" ${CUR_PARAM[*]}

    done

    return

}



#===================================================================
# Scan python file for handler/forge
#===================================================================
function fn_scan_handler_forge() {
#process single file

    CUR_DIR=$1
    CUR_FILE=$2

    TGT_DIR=${TGT_BASE_DIR}/"service"/${CUR_FILE/Handler/}    #remove Handler
    TGT_DIR=${TGT_DIR/.py/}                         #remove .py
    TGT_DIR=${TGT_DIR,,}                            #tolower

    #for tmp test
    if [ "${CUR_FILE}" != "SessionHandler.py" ]
    then
        return
    fi

    #create subdir in out.tmp
    mkdir -p ${TGT_DIR}

    fn_resolve_api "${CUR_DIR}" "${CUR_FILE}" "${TGT_DIR}"

    return

}

#===================================================================
# Scan python file for aws
#===================================================================
function fn_scan_aws() {
#
    return

    CUR_DIR=$1
    SERVICE=$2
    #echo $CUR_DIR

    #service
    echo
    echo "#======================================================="
    echo "#  SERVICE: ${SERVICE}"
    echo "#======================================================="

    #for tmp test
    #if [ "${SERVICE}" != "EC2" ]
    #then
    #    return
    #fi

    if [ "${SERVICE}" == "AWSUtil.py" ]
    then
    #AWSUtil#########################

        CUR_FILE=${SERVICE}
        SERVICE=${SERVICE/.py/} #remove .py

        TGT_DIR=${TGT_BASE_DIR}/"service"/aws/${SERVICE,,}
        #create subdir in out.tmp
        mkdir -p ${TGT_DIR}

        fn_resolve_api "${CUR_DIR}" "${CUR_FILE}" "${TGT_DIR}"

    else
    #Except AWSUtil###################

        for RESOURCE in `ls ${CUR_DIR}/${SERVICE} | grep -v "__init__"`
        do
        #resource
            CUR_FILE=${RESOURCE}
            RESOURCE=${RESOURCE/.py/}
            echo
            echo "#-------------------------------------------------------"
            echo "#   RESOURCE: ${RESOURCE}"
            echo "#-------------------------------------------------------"

            TGT_DIR=${TGT_BASE_DIR}/"service"/aws/${SERVICE,,}/${RESOURCE,,}
            #create subdir in out.tmp
            mkdir -p ${TGT_DIR}

            fn_resolve_api "${CUR_DIR}/${SERVICE}" "${CUR_FILE}" "${TGT_DIR}"
        done

    fi


    return
}

###########################################################
# main
###########################################################
for (( i = 0 ; i < ${#SRC_DIR[@]} ; i++ ))
do
    CUR_SRC_DIR=${SRC_BASE_DIR_}/${SRC_DIR[$i]}

    for LINE in `ls ${CUR_SRC_DIR} | grep -v "__init__" | grep -v "View" | grep -v "EventHandler"`
    do
        echo
        echo "########################################################"
        echo "#Processing "${SRC_DIR[$i]}
        echo "########################################################"
        if [ "${SRC_DIR[$i]}" == "Handler" -o "${SRC_DIR[$i]}" == "Forge" ]
        then
            fn_scan_handler_forge "${CUR_SRC_DIR}" "${LINE}"
        elif [ "${SRC_DIR[$i]}" == "AWS" ]
        then
            fn_scan_aws "${CUR_SRC_DIR}" "${LINE}"
        fi
    done
done

