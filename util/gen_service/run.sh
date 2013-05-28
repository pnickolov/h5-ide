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

#delete old file
rm ${TGT_BASE_DIR} -rf

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
    RESOURCE_URL=""
    API_TYPE=""
    api_type=""
    SERVICE_NAME=`echo ${__TGT_DIR_SERVICE} | awk 'BEGIN{FS="[/]"}{printf "%s",$(NF-1)}'`



    if [ "${__TYPE}" == "aws"  ]
    then
        SERVICE_URL="aws\/"${SERVICE_NAME}
        RESOURCE_URL="aws\/"${SERVICE_NAME}"\/"${_RESOURCE_l}
        API_TYPE="AWS"
        api_type="aws"
        __TGT_DIR_TEST=${__TGT_DIR_TEST/\/${_RESOURCE_l}/} #remove last field

        #special process RESOURCE_URL
        if [ "${_RESOURCE_l}" == "ec2" -o "${_RESOURCE_l}" == "elb" -o "${_RESOURCE_l}" == "iam" -o "${_RESOURCE_l}" == "vpc" ]
        then
            RESOURCE_URL="aws\/"${SERVICE_NAME}
        elif [ "${_RESOURCE_l}" == "vpngateway" ]
        then
            RESOURCE_URL="aws\/"${SERVICE_NAME}"\/vgw"
        elif [ "${_RESOURCE_l}" == "customergateway" ]
        then
            RESOURCE_URL="aws\/"${SERVICE_NAME}"\/cgw"
        elif [ "${_RESOURCE_l}" == "internetgateway" ]
        then
            RESOURCE_URL="aws\/"${SERVICE_NAME}"\/igw"
        fi

    elif [ "${__TYPE}" == "awsutil"  ]
    then
        SERVICE_URL="aws"
        RESOURCE_URL=${SERVICE_URL}
        API_TYPE="AWS"
        api_type="aws"
        SERVICE_NAME="aws"
    else
        SERVICE_URL=${_RESOURCE_l}
        RESOURCE_URL=${SERVICE_URL}
        API_TYPE="Forge"
        api_type="forge"
    fi

    echo
    echo "#......................................................."
    echo "# SRC_FILE: "${__CUR_DIR}/${__CUR_FILE}
    echo "# TGT_DIR_SERVICE : "${__TGT_DIR_SERVICE}
    echo "# TGT_DIR_TEST    : "${__TGT_DIR_TEST}
    echo "# SERVICE_URL     : "${SERVICE_URL}
    echo "# RESOURCE_URL    : "${RESOURCE_URL}
    echo "# SERVICE_NAME    : "${SERVICE_NAME}
    echo "# RESOURCE_NAME   : "${_RESOURCE_l}
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
    | sed -e ":a;N;$ s/@@resource-url/${RESOURCE_URL}/g;ba" \
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

    if [ "${_RESOURCE_l}" != "session" ]
    then
        #remove "}"
        sed '$d' ${__TGT_DIR_TEST}/config.coffee > ${__TGT_DIR_TEST}/config.coffee.tmp
        mv -f ${__TGT_DIR_TEST}/config.coffee.tmp ${__TGT_DIR_TEST}/config.coffee

        if [ "${__TYPE}" == "aws"  ]
        then
            echo -e "\n        #${_RESOURCE_l} service\n\
        '${_RESOURCE_l}_vo'        : 'service/${SERVICE_URL/\\/}/${_RESOURCE_l}/${_RESOURCE_l}_vo'\n\
        '${_RESOURCE_l}_parser'    : 'service/${SERVICE_URL/\\/}/${_RESOURCE_l}/${_RESOURCE_l}_parser'\n\
        '${_RESOURCE_l}_service'   : 'service/${SERVICE_URL/\\/}/${_RESOURCE_l}/${_RESOURCE_l}_service'\n\
}#end">> ${__TGT_DIR_TEST}/config.coffee
        else
            echo -e "\n        #${_RESOURCE_l} service\n\
        '${_RESOURCE_l}_vo'        : 'service/${SERVICE_URL/\\/}/${_RESOURCE_l}_vo'\n\
        '${_RESOURCE_l}_parser'    : 'service/${SERVICE_URL/\\/}/${_RESOURCE_l}_parser'\n\
        '${_RESOURCE_l}_service'   : 'service/${SERVICE_URL/\\/}/${_RESOURCE_l}_service'\n\
}#end">> ${__TGT_DIR_TEST}/config.coffee
        fi

    fi

    echo "6.generate test/testsuite.html"
    if [ ! -f ${__TGT_DIR_TEST}/testsuite.html ]
    then
        sed -e ":a;N;$ s/@@resource-name/${_RESOURCE_l}/g;ba" ${TMPL_BASE_DIR}/test/testsuite.html \
        | sed -e ":a;N;$ s/@@service-url/${SERVICE_URL}/g;ba" \
        > ${__TGT_DIR_TEST}/testsuite.html
    fi

    echo "7.generate test/testsuite.coffee.head (head)"
    _MODULE_LIST="'\/test\/service\/${SERVICE_URL}\/module_${_RESOURCE_l}.js'"
    if [ ! -f ${__TGT_DIR_TEST}/testsuite.coffee ]
    then
        sed -e ":a;N;$ s/@@resource-name/${_RESOURCE_l}/g;ba" ${TMPL_BASE_DIR}/test/testsuite.coffee.head \
        | sed -e ":a;N;$ s/@@create-date/`date "+%Y-%m-%d %H:%M:%S"`/g;ba" \
        | sed -e ":a;N;$ s/@@api-type/${api_type}/g;ba" \
        > ${__TGT_DIR_TEST}/testsuite.coffee
    fi

    echo "8.generate test/test_module.coffee.head (head)"
    if [ "${_RESOURCE_l}" != "session" ]
    then
        sed -e ":a;N;$ s/@@resource-name/${_RESOURCE_l}/g;ba" ${TMPL_BASE_DIR}/test/module.coffee.head \
        | sed -e ":a;N;$ s/@@create-date/`date "+%Y-%m-%d %H:%M:%S"`/g;ba" \
        | sed -e ":a;N;$ s/@@service-url/${SERVICE_URL}/g;ba" \
        > ${__TGT_DIR_TEST}/module_${_RESOURCE_l}.coffee
    else
    #special process session
        sed -e ":a;N;$ s/session_service, //g;ba" ${TMPL_BASE_DIR}/test/module.coffee.head \
        | sed -e ":a;N;$ s/'session_service', //g;ba" \
        | sed -e ":a;N;$ s/@@create-date/`date "+%Y-%m-%d %H:%M:%S"`/g;ba" \
        | sed -e ":a;N;$ s/@@service-url/${SERVICE_URL}/g;ba" \
        | sed -e ":a;N;$ s/@@resource-name/${_RESOURCE_l}/g;ba" \
        > ${__TGT_DIR_TEST}/module_${_RESOURCE_l}.coffee
    fi

    _LAST_API=""
    #// loop by API_NAME ////////////////////////////////////////////////////////////////////
    for (( j = 1 ; j <= ${#API_NAME[@]} ; j++ ))
    do

        #for tmp test
        #if [ $j -ge 2 ]
        #then
        #    break
        #fi

        _CUR_ORIGIN=`echo ${ORIGIN[$j]} | sed 's/ *$//' ` #delete tail space
        #echo "origin:"${_CUR_ORIGIN}

        _CUR_API=${API_NAME[$j]}
        #echo "api   : "${_CUR_API}

        #special process api named "public"
        if [ "${_CUR_API}" == "public"  ]
        then
            _CUR_API="Public"
        fi

        #set_aaa => SetAaa
        _FUNC=`echo "${_CUR_API}" | awk '{len=split($0,a,"_");for (i=1;i<=len;i++){printf "%s%s",toupper(substr(a[i],0,1)),substr(a[i],2) } }'`

        _PARAM_DEF=""  #in define
        _PARAM_LIST="" #in invoke
        _PARAM_DEFAULT="" #default param (not include username,region_name,session_id)

        P_NUM='echo ${#API_PARAM_'${j}'[@]}'
        P_NUM=`eval ${P_NUM}`

        CUR_PARAM=()
        CUR_PARAM_DEF=()
        for (( k = 1 ; k <= ${P_NUM} ; k++ ))
        do
            TMP='${API_PARAM_'${j}'[$k]}'

            CUR_PARAM[$k]=`eval "echo $TMP" | awk 'BEGIN{FS="[=]"}{printf $1}' `
            #process python constant to javascript
            CUR_PARAM_DEF[$k]=`eval "echo $TMP" | sed "s/None/null/g" | sed "s/False/false/g" | sed "s/True/true/g" `

            CUR_PARAM_DEFAULT=`echo "${CUR_PARAM[$k]}" | awk '{printf $1}' | awk  'BEGIN{FS="[=]"}{if (NF==1){printf "            %s = null",$0}else{printf "            %s = %s",$1,$2}}'`

            #echo "    param> "${CUR_PARAM[$k]}
            if [ $k -eq 1 ]
            then
                _PARAM_LIST=${CUR_PARAM[$k]}
                _PARAM_DEF=${CUR_PARAM_DEF[$k]}
                if [ "${CUR_PARAM[$k]}" != "username" -a "${CUR_PARAM[$k]}" != "session_id" -a "${CUR_PARAM[$k]}" != "region_name" ]
                then
                    if [ "${_PARAM_DEFAULT}" == "" ]
                    then
                        _PARAM_DEFAULT=${CUR_PARAM_DEFAULT}
                    else
                        _PARAM_DEFAULT=${_PARAM_DEFAULT}"\n"${CUR_PARAM_DEFAULT}
                    fi
                fi
            else
                _PARAM_LIST=${_PARAM_LIST}", "${CUR_PARAM[$k]}
                _PARAM_DEF=${_PARAM_DEF}", "${CUR_PARAM_DEF[$k]}
                if [ "${CUR_PARAM[$k]}" != "username" -a "${CUR_PARAM[$k]}" != "session_id" -a "${CUR_PARAM[$k]}" != "region_name" ]
                then
                    if [ "${_PARAM_DEFAULT}" == "" ]
                    then
                        _PARAM_DEFAULT=${CUR_PARAM_DEFAULT}
                    else
                        _PARAM_DEFAULT=${_PARAM_DEFAULT}"\n"${CUR_PARAM_DEFAULT}
                    fi
                fi
            fi
        done
        eval "API_PARAM_${j}=()" #clear


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

        #echo "CUR_PARAM: "${CUR_PARAM[*]}
        #echo "_PARAM_DEF:"${_PARAM_DEF}
        #echo "_PARAM_LIST:"${_PARAM_LIST}

        #1.append api ( ${_CUR_API} ) to ${_RESOURCE_l}_service.coffee
        sed -e ":a;N;$ s/@@resource-name/${_RESOURCE_l}/g;ba" ${TMPL_BASE_DIR}/service/service.coffee.api \
        | sed -e ":a;N;$ s/@@api-name/${_CUR_API}/g;ba" \
        | sed -e ":a;N;$ s/@@origin/${_CUR_ORIGIN}/g;ba" \
        | sed -e ":a;N;$ s/@@param-def/${_PARAM_DEF}/g;ba" \
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


        #3.appent qunit test for  ( ${_CUR_API} )  to ${__TGT_DIR_TEST}/module_${_RESOURCE_l}.coffee
        if [ "${NEED_RESOLVE}" != "" -a "${_CUR_API}" != "login"  ]
        then
        #Describe/List/Get
            if [ "${_LAST_API}" == "" ]
            then
                sed -e ":a;N;$ s/@@resource-name/${_RESOURCE_l}/g;ba" ${TMPL_BASE_DIR}/test/module.coffee.api \
                | sed -e ":a;N;$ s/@@service-url/${SERVICE_URL}/g;ba" \
                | sed -e ":a;N;$ s/@@param-default/${_PARAM_DEFAULT}/g;ba" \
                | sed -e ":a;N;$ s/@@param-list/${_PARAM_LIST}/g;ba" \
                | sed -e ":a;N;$ s/@@api-name/${_CUR_API}/g;ba" \
                | sed -e ":a;N;$ s/#@@last-api()//g;ba" \
                | sed -e ":a;N;$ s/@@api-type/${api_type}/g;ba" \
                >> ${__TGT_DIR_TEST}/module_${_RESOURCE_l}.coffee
            else
                sed -e ":a;N;$ s/@@resource-name/${_RESOURCE_l}/g;ba" ${TMPL_BASE_DIR}/test/module.coffee.api \
                | sed -e ":a;N;$ s/@@service-url/${SERVICE_URL}/g;ba" \
                | sed -e ":a;N;$ s/@@param-default/${_PARAM_DEFAULT}/g;ba" \
                | sed -e ":a;N;$ s/@@param-list/${_PARAM_LIST}/g;ba" \
                | sed -e ":a;N;$ s/@@api-name/${_CUR_API}/g;ba" \
                | sed -e ":a;N;$ s/#@@last-api/test_${_LAST_API}/g;ba" \
                | sed -e ":a;N;$ s/@@api-type/${api_type}/g;ba" \
                >> ${__TGT_DIR_TEST}/module_${_RESOURCE_l}.coffee
            fi
        fi

        _LAST_API=${_CUR_API}

    done

    echo "9.append public api list to ${_RESOURCE_l}_service.coffee"
    echo -e "\n    #############################################################\n\
    #public${_PUBLIC_API_LIST}\n" >> ${__TGT_DIR_SERVICE}/${_RESOURCE_l}_service.coffee

    echo "10.append public parser list to ${_RESOURCE_l}_parser.coffee"
    echo -e "\n    #############################################################\n\
    #public${_PUBLIC_PARSER_LIST}\n" >> ${__TGT_DIR_SERVICE}/${_RESOURCE_l}_parser.coffee

    echo "11.append null to module_${_RESOURCE_l}.coffee"
    echo -e "\n    test_${_LAST_API}()\n" >> ${__TGT_DIR_TEST}/module_${_RESOURCE_l}.coffee

    echo "12.replace model list to ${__TGT_DIR_TEST}/testsuite.coffee"
    echo "_MODULE_LIST:"${_MODULE_LIST}
    sed -e ":a;N;$ s/##@@module-list/${_MODULE_LIST},\n\t##@@module-list/g;ba" ${__TGT_DIR_TEST}/testsuite.coffee \
     >  ${__TGT_DIR_TEST}/testsuite.coffee.tmp
    mv -f ${__TGT_DIR_TEST}/testsuite.coffee.tmp ${__TGT_DIR_TEST}/testsuite.coffee

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
    #if [ "${CUR_FILE}" != "SessionHandler.py" ]
    #then
    #    return
    #fi

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


    if [ "${SERVICE}" == "SNS" ]
    then
        return
    fi

    #for tmp test

    #if [ "${SERVICE}" != "VPC" ]
    #then
    #    return
    #fi

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

echo -e "define [], () ->\n\
    username    = ''\n\
    password    = ''\n\
\n\
    #public\n\
    username    : username,\n\
    password    : password\n\
\n\
" > ${TGT_BASE_DIR}/test/test_util.coffee

