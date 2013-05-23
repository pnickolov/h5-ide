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
# 1.Resolve api and param in python file, 2.generate coffee file
#===================================================================
function fn_generate_coffee() {

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

    ## generate coffee file ####################################################

    TMP=${CUR_FILE/Handler/}    #remove Handler
    _SERVICE_u=${TMP/.py/}      #remove .py -> eg: Session
    _SERVICE_l=${_SERVICE_u,,}     #tolower    -> eg: session

    echo "1.generate service.coffee (head)"
    sed -e ":a;N;$ s/@@service-name/${_SERVICE_l}/g;ba" ${TMPL_BASE_DIR}/service.coffee.head \
    | sed -e ":a;N;$ s/@@create-date/`date "+%Y-%m-%d %H:%M:%S"`/g;ba" \
    > ${TGT_DIR}/${_SERVICE_l}_service.coffee

    echo "2.generate parser.coffee (head)"
    sed -e ":a;N;$ s/@@service-name/${_SERVICE_l}/g;ba" ${TMPL_BASE_DIR}/parser.coffee.head \
    | sed -e ":a;N;$ s/@@create-date/`date "+%Y-%m-%d %H:%M:%S"`/g;ba" \
    > ${TGT_DIR}/${_SERVICE_l}_parser.coffee

    echo "3.generate vo.coffee"
    sed -e ":a;N;$ s/@@service-name/${_SERVICE_l}/g;ba" ${TMPL_BASE_DIR}/vo.coffee.tmpl \
    | sed -e ":a;N;$ s/@@create-date/`date "+%Y-%m-%d %H:%M:%S"`/g;ba" \
    > ${TGT_DIR}/${_SERVICE_l}_vo.coffee

    echo "4.append api handler to service and parser"
    _PUBLIC_API_LIST=""
    #loop by API_NAME
    for (( j = 1 ; j <= ${#API_NAME[@]} ; j++ ))
    do

        _CUR_ORIGIN=${ORIGIN[$j]}
        #echo "origin:"${_CUR_ORIGIN}

        _CUR_API=${API_NAME[$j]}
        #echo "api   : "${_CUR_API}

        #set_aaa => SetAaa
        _FUNC=`echo "${_CUR_API}" | awk '{len=split($0,a,"_");for (i=1;i<=len;i++){printf "%s%s",toupper(substr(a[i],0,1)),substr(a[i],2) } }'`


        _PARAM_LIST=""

        P_NUM='echo ${#API_PARAM_'${j}'[@]}'
        P_NUM=`eval ${P_NUM}`

        CUR_PARAM=()
        for (( k = 1 ; k <= ${P_NUM} ; k++ ))
        do
            TMP='${API_PARAM_'${j}'[$k]}'
            CUR_PARAM[$k]=`eval "echo $TMP" | awk 'BEGIN{FS="[=]"}{printf $1}' `
            #echo "    param> "${CUR_PARAM[$k]}
            if [ $k -eq 1 ]
            then
                _PARAM_LIST=${CUR_PARAM[$k]}
            else
                _PARAM_LIST=${_PARAM_LIST}", "${CUR_PARAM[$k]}
            fi
        done

        #echo "CUR_PARAM: "${#CUR_PARAM[@]}

        echo " > ${_CUR_API} "
        #1.append api ( ${_CUR_API} ) to ${_SERVICE_l}_service.coffee
        sed -e ":a;N;$ s/@@service-name/${_SERVICE_l}/g;ba" ${TMPL_BASE_DIR}/service.coffee.api \
        | sed -e ":a;N;$ s/@@api-name/${_CUR_API}/g;ba" \
        | sed -e ":a;N;$ s/@@origin/${_CUR_ORIGIN}/g;ba" \
        | sed -e ":a;N;$ s/@@param-list/${_PARAM_LIST}/g;ba" \
        | sed -e ":a;N;$ s/@@parser-func/parser${_FUNC}Return/g;ba" \
        >> ${TGT_DIR}/${_SERVICE_l}_service.coffee

        _PUBLIC_API_LIST="\tparser${_FUNC}Return \t: parser${_FUNC}Return\n"${_PUBLIC_API_LIST}

        #2.append api ( ${_CUR_API} ) to ${_SERVICE_l}_parser.coffee
        sed -e ":a;N;$ s/@@service-name/${_SERVICE_l}/g;ba" ${TMPL_BASE_DIR}/parser.coffee.api \
        | sed -e ":a;N;$ s/@@api-name/${_CUR_API}/g;ba" \
        | sed -e ":a;N;$ s/@@parser-func/parser${_FUNC}Return/g;ba" \
        | sed -e ":a;N;$ s/@@resolve-func/resolve${_FUNC}VO/g;ba" \
        >> ${TGT_DIR}/${_SERVICE_l}_parser.coffee

    done

        echo "5.append public api list to ${_SERVICE_l}_service.coffee"
        echo -e "${_PUBLIC_API_LIST}" >> ${TGT_DIR}/${_SERVICE_l}_service.coffee

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

    fn_generate_coffee "${CUR_DIR}" "${CUR_FILE}" "${TGT_DIR}"

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

        fn_generate_coffee "${CUR_DIR}" "${CUR_FILE}" "${TGT_DIR}"

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

