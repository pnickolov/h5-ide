#!/bin/bash
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

    __TYPE=$1
    __CUR_DIR=$2
    __CUR_FILE=$3
    __TGT_DIR_SERVICE=$4
    __TGT_DIR_TEST=${__TGT_DIR_SERVICE/\/service\//\/test\/} #replace /service/ with /test/


    API_NAME=()
    API_PARAM=()

    #Resolve all api and params in ${__CUR_DIR}/${__CUR_FILE}
    __CMD=`cat ${__CUR_DIR}/${__CUR_FILE} | grep "def " | grep "self" | grep -v "def _" | grep -v "def test" | grep -v "#def" | grep -v "params_" | \
        awk 'BEGIN{FS="[ (:)]"}{sub("    ","\t",$0); printf "ORIGIN[%d]=\"%s\";API_NAME[%d]=\"%s\";",NR,$0,NR,$2; for ( x=4; x<=NF-2; x++){ gsub(",","",$x); printf "API_PARAM_%s[%s]=\"%s\";",NR,x-3,$x};printf "\n" }' `
    #Generate API_NAME and API_PARAM
    eval ${__CMD}

    ## generate coffee file ####################################################

    TMP=${__CUR_FILE/Handler/}  #remove Handler
    TMP=${TMP/Util/}            #remove Util
    _RESOURCE_u=${TMP/.py/}      #remove .py -> eg: Session
    _RESOURCE_l=${_RESOURCE_u,,}  #tolower    -> eg: session


    SERVICE_URL=""
    API_TYPE=""
    api_type=""
    SERVICE_NAME=`echo ${__TGT_DIR_SERVICE} | awk 'BEGIN{FS="[/]"}{printf "%s",$(NF-1)}'`


    if [ "${__TYPE}" == "aws"  ]
    then
        SERVICE_URL="aws\/"${SERVICE_NAME}
        API_TYPE="AWS"
        api_type="aws"
        __TGT_DIR_TEST=${__TGT_DIR_TEST/\/${_RESOURCE_l}/} #remove last field

    elif [ "${__TYPE}" == "awsutil"  ]
    then
        SERVICE_URL="aws"
        API_TYPE="AWS"
        api_type="aws"
        SERVICE_NAME="aws"
    else
        SERVICE_URL=${_RESOURCE_l}
        API_TYPE="Forge"
        api_type="forge"
    fi

    echo
    echo "#......................................................."
    echo "# SRC_FILE: "${__CUR_DIR}/${__CUR_FILE}
    echo "# TGT_DIR_SERVICE : "${__TGT_DIR_SERVICE}
    echo "# TGT_DIR_TEST    : "${__TGT_DIR_TEST}
    echo "# SERVICE_URL     : "${SERVICE_URL}
    echo "# SERVICE_NAME    : "${SERVICE_NAME}
    echo "#......................................................."

    if [ ! -d ${__TGT_DIR_SERVICE} ]
    then
        mkdir -p ${__TGT_DIR_SERVICE}
    fi

    if [ ! -d ${__TGT_DIR_TEST} ]
    then
        mkdir -p ${__TGT_DIR_TEST}
    fi


    #// Generate service head ////////////////////////////////////////////////////////////
    echo "1.generate service/service.coffee (head)"
    sed -e ":a;N;$ s/@@resource-name/${_RESOURCE_l}/g;ba" ${TMPL_BASE_DIR}/service/service.coffee.head \
    | sed -e ":a;N;$ s/@@create-date/`date "+%Y-%m-%d %H:%M:%S"`/g;ba" \
    | sed -e ":a;N;$ s/@@service-url/${SERVICE_URL}/g;ba" \
    | sed -e ":a;N;$ s/@@api-type/${api_type}/g;ba" \
    > ${__TGT_DIR_SERVICE}/${_RESOURCE_l}_service.coffee

    echo "2.generate service/parser.coffee (head)"
    sed -e ":a;N;$ s/@@resource-name/${_RESOURCE_l}/g;ba" ${TMPL_BASE_DIR}/service/parser.coffee.head \
    | sed -e ":a;N;$ s/@@create-date/`date "+%Y-%m-%d %H:%M:%S"`/g;ba" \
    > ${__TGT_DIR_SERVICE}/${_RESOURCE_l}_parser.coffee

    echo "3.generate service/vo.coffee"
    sed -e ":a;N;$ s/@@resource-name/${_RESOURCE_l}/g;ba" ${TMPL_BASE_DIR}/service/vo.coffee.tmpl \
    | sed -e ":a;N;$ s/@@create-date/`date "+%Y-%m-%d %H:%M:%S"`/g;ba" \
    > ${__TGT_DIR_SERVICE}/${_RESOURCE_l}_vo.coffee

    echo "4.append api handler to service and parser"
    _PUBLIC_API_LIST=""
    _PUBLIC_PARSER_LIST=""

    #// Generate qunit test head ////////////////////////////////////////////////////////////
    echo "5.generate test/config.coffee (head)"
    if [ ! -f ${__TGT_DIR_TEST}/config.coffee ]
    then
        sed -e ":a;N;$ s/@@resource-name/${_RESOURCE_l}/g;ba" ${TMPL_BASE_DIR}/test/config.coffee.head \
        | sed -e ":a;N;$ s/@@create-date/`date "+%Y-%m-%d %H:%M:%S"`/g;ba" \
        | sed -e ":a;N;$ s/@@service-url/${SERVICE_URL}/g;ba" \
        > ${__TGT_DIR_TEST}/config.coffee
    fi

    echo "6.generate test/testsuite.html"
    if [ ! -f ${__TGT_DIR_TEST}/testsuite.html ]
    then
        sed -e ":a;N;$ s/@@resource-name/${_RESOURCE_l}/g;ba" ${TMPL_BASE_DIR}/test/testsuite.html \
        | sed -e ":a;N;$ s/@@service-url/${SERVICE_URL}/g;ba" \
        > ${__TGT_DIR_TEST}/testsuite.html
    fi

    echo "7.generate test/testsuite.coffee.head (head)"
    if [ ! -f ${__TGT_DIR_TEST}/testsuite.coffee ]
    then
        sed -e ":a;N;$ s/@@resource-name/${_RESOURCE_l}/g;ba" ${TMPL_BASE_DIR}/test/testsuite.coffee.head \
        | sed -e ":a;N;$ s/@@create-date/`date "+%Y-%m-%d %H:%M:%S"`/g;ba" \
        | sed -e ":a;N;$ s/@@api-type/${api_type}/g;ba" \
        > ${__TGT_DIR_TEST}/testsuite.coffee
    fi

    echo "8.generate test/test_module.coffee.head (head)"
    sed -e ":a;N;$ s/@@resource-name/${_RESOURCE_l}/g;ba" ${TMPL_BASE_DIR}/test/module.coffee.head \
    | sed -e ":a;N;$ s/@@create-date/`date "+%Y-%m-%d %H:%M:%S"`/g;ba" \
    | sed -e ":a;N;$ s/@@api-type/${api_type}/g;ba" \
    > ${__TGT_DIR_TEST}/module_${_RESOURCE_l}.coffee


    return

    #// loop by API_NAME ////////////////////////////////////////////////////////////////////
    for (( j = 1 ; j <= ${#API_NAME[@]} ; j++ ))
    do

        _CUR_ORIGIN=${ORIGIN[$j]}
        #echo "origin:"${_CUR_ORIGIN}

        _CUR_API=${API_NAME[$j]}
        #echo "api   : "${_CUR_API}

        #set_aaa => SetAaa
        _FUNC=`echo "${_CUR_API}" | awk '{len=split($0,a,"_");for (i=1;i<=len;i++){printf "%s%s",toupper(substr(a[i],0,1)),substr(a[i],2) } }'`

        _PARAM_LIST_DEF=""  #in define
        _PARAM_LIST=""      #in invoke

        P_NUM='echo ${#API_PARAM_'${j}'[@]}'
        P_NUM=`eval ${P_NUM}`

        CUR_PARAM=()
        for (( k = 1 ; k <= ${P_NUM} ; k++ ))
        do
            TMP='${API_PARAM_'${j}'[$k]}'

            CUR_PARAM[$k]=`eval "echo $TMP" | awk 'BEGIN{FS="[=]"}{printf $1}' `
            CUR_PARAM_DEF[$k]=`eval "echo $TMP" | sed "s/None/null/g" `
            #echo "    param> "${CUR_PARAM[$k]}
            if [ $k -eq 1 ]
            then
                _PARAM_LIST=${CUR_PARAM[$k]}
                _PARAM_LIST_DEF=${CUR_PARAM_DEF[$k]}
            else
                _PARAM_LIST=${_PARAM_LIST}", "${CUR_PARAM[$k]}
                _PARAM_LIST_DEF=${_PARAM_LIST_DEF}", "${CUR_PARAM_DEF[$k]}
            fi
        done

        #echo "CUR_PARAM: "${#CUR_PARAM[@]}

        NEED_RESOLVE=""
        if [ "${__TYPE}" == "aws"  ]
        then
        #api in aws that Start with Describe/Get/List need resolve
            NEED_RESOLVE=`echo "${_CUR_API}"  | grep -E "^Describe|^Get|^List" | wc -l `
            if [ "${NEED_RESOLVE}" -eq 0  ]
            then
                NEED_RESOLVE=""
                echo " > ${_CUR_API} "
            else
                NEED_RESOLVE=".resolve"
                echo " > ${_CUR_API} (need resolve)"
            fi
        else
        #all api in awsutil/forge/handler need resolve
            NEED_RESOLVE=".resolve"
            echo " > ${_CUR_API} (need resolve)"
        fi

        #1.append api ( ${_CUR_API} ) to ${_RESOURCE_l}_service.coffee
        sed -e ":a;N;$ s/@@resource-name/${_RESOURCE_l}/g;ba" ${TMPL_BASE_DIR}/service/service.coffee.api \
        | sed -e ":a;N;$ s/@@api-name/${_CUR_API}/g;ba" \
        | sed -e ":a;N;$ s/@@origin/${_CUR_ORIGIN}/g;ba" \
        | sed -e ":a;N;$ s/@@param-list-def/${_PARAM_LIST_DEF}/g;ba" \
        | sed -e ":a;N;$ s/@@param-list/${_PARAM_LIST}/g;ba" \
        | sed -e ":a;N;$ s/@@parser-func/parser${_FUNC}Return/g;ba" \
        >> ${__TGT_DIR_SERVICE}/${_RESOURCE_l}_service.coffee

        #public parser func
        _TMP=`echo "parser${_FUNC}Return" | awk '{printf "    %-40s : %s\n",$0,$0}'`
        _PUBLIC_PARSER_LIST=${_PUBLIC_PARSER_LIST}"\n"${_TMP}

        #public api func
        _TMP=`echo "${_CUR_API}" | awk '{printf "    %-28s : %s\n",$0,$0}'`
        _PUBLIC_API_LIST=${_PUBLIC_API_LIST}"\n"${_TMP}

        #2.append api ( ${_CUR_API} ) to ${_RESOURCE_l}_parser.coffee
        sed -e ":a;N;$ s/@@resource-name/${_RESOURCE_l}/g;ba" ${TMPL_BASE_DIR}/service/parser.coffee.api${NEED_RESOLVE} \
        | sed -e ":a;N;$ s/@@api-name/${_CUR_API}/g;ba" \
        | sed -e ":a;N;$ s/@@parser-func/parser${_FUNC}Return/g;ba" \
        | sed -e ":a;N;$ s/@@resolve-func/resolve${_FUNC}Result/g;ba" \
        | sed -e ":a;N;$ s/@@api-type/${api_type}/g;ba" \
        | sed -e ":a;N;$ s/@@API-TYPE/${API_TYPE}/g;ba" \
        >> ${__TGT_DIR_SERVICE}/${_RESOURCE_l}_parser.coffee

    done

    echo "5.append public api list to ${_RESOURCE_l}_service.coffee"
    echo -e "\n    #############################################################\n\
    #public ${_PUBLIC_API_LIST}" >> ${__TGT_DIR_SERVICE}/${_RESOURCE_l}_service.coffee

    echo "6.append public parser list to ${_RESOURCE_l}_parser.coffee"
    echo -e "\n    #############################################################\n\
    #public ${_PUBLIC_PARSER_LIST}" >> ${__TGT_DIR_SERVICE}/${_RESOURCE_l}_parser.coffee

    echo

    return


}



#===================================================================
# Scan python file for handler/forge
#===================================================================
function fn_scan_handler_forge() {
#process single file

    CUR_DIR=$1
    CUR_FILE=$2

    #for tmp test
    if [ "${CUR_FILE}" != "SessionHandler.py" ]
    then
        return
    fi

    echo "########################################################"
    echo "#Processing "`echo ${CUR_DIR} | awk 'BEGIN{FS="[/]"}{print $(NF) }' `" - "${CUR_FILE}
    echo "########################################################"

    TGT_DIR=${TGT_BASE_DIR}/"service"/${CUR_FILE/Handler/}      #remove Handler
    TGT_DIR=${TGT_DIR/.py/}                                     #remove .py
    TGT_DIR=${TGT_DIR,,}                                        #tolower

    #create subdir in out.tmp
    mkdir -p ${TGT_DIR}                             #create out.tmp/service/

    fn_generate_coffee "forge" "${CUR_DIR}" "${CUR_FILE}" "${TGT_DIR}"

    return

}

#===================================================================
# Scan python file for aws
#===================================================================
function fn_scan_aws() {

    CUR_DIR=$1
    SERVICE=$2
    #echo $CUR_DIR

    #for tmp test
    if [ "${SERVICE}" != "EC2" ]
    then
        return
    fi

    #service
    echo
    echo "#======================================================="
    echo "#  SERVICE: ${SERVICE}"
    echo "#======================================================="

    if [ "${SERVICE}" == "AWSUtil.py" ]
    then
    #AWSUtil#########################

        CUR_FILE=${SERVICE}
        SERVICE=${SERVICE/.py/} #remove .py

        echo "########################################################"
        echo "#Processing AWS - "${CUR_FILE}
        echo "########################################################"

        _RESOURCE=${SERVICE/Util/}
        TGT_DIR=${TGT_BASE_DIR}/"service"/aws/${_RESOURCE,,}  #lower
        #create subdir in out.tmp
        mkdir -p ${TGT_DIR}                             #create out.tmp/service/

        fn_generate_coffee "awsutil" "${CUR_DIR}" "${CUR_FILE}" "${TGT_DIR}"

    else
    #Except AWSUtil###################

        for RESOURCE in `ls ${CUR_DIR}/${SERVICE} | grep -v "__init__"`
        do
        #resource
            CUR_FILE=${RESOURCE}
            RESOURCE=${RESOURCE/.py/}

            echo "########################################################"
            echo "#Processing AWS - "${SERVICE}" - "${CUR_FILE}
            echo "########################################################"

            echo
            echo "#-------------------------------------------------------"
            echo "#   RESOURCE: ${RESOURCE}"
            echo "#-------------------------------------------------------"

            _RESOURCE=${RESOURCE/Util/}                                          #remove util
            TGT_DIR=${TGT_BASE_DIR}/"service"/aws/${SERVICE,,}/${_RESOURCE,,}    #lower

            #create subdir in out.tmp
            mkdir -p ${TGT_DIR}                             #create out.tmp/service/

            fn_generate_coffee "aws" "${CUR_DIR}/${SERVICE}" "${CUR_FILE}" "${TGT_DIR}"
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
        if [ "${SRC_DIR[$i]}" == "Handler" -o "${SRC_DIR[$i]}" == "Forge" ]
        then
            fn_scan_handler_forge "${CUR_SRC_DIR}" "${LINE}"
        elif [ "${SRC_DIR[$i]}" == "AWS" ]
        then
            fn_scan_aws "${CUR_SRC_DIR}" "${LINE}"
        fi
    done
done

