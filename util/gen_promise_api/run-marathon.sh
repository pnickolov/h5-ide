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
SRC_DIR=("Marathon")

#javascript service dir
#TGT_BASE_DIR=${SH_BASE_DIR}/"../../src/service"
TGT_BASE_DIR=${SH_BASE_DIR}/"out.tmp"

#delete old file
rm ${TGT_BASE_DIR} -rf

mkdir -p ${TGT_BASE_DIR}/service

#template file dir
TMPL_BASE_DIR=${SH_BASE_DIR}/"template"

#
SERVICE_FILELIST=""

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
        SERVICE_URL=${SERVICE_NAME}
        RESOURCE_URL=${SERVICE_NAME}"/"${_RESOURCE_l}
        API_TYPE="AWS"
        api_type="aws"
        __TGT_DIR_TEST=${__TGT_DIR_TEST//${_RESOURCE_l}/} #remove last field

        #special process RESOURCE_URL
        if [ "${SERVICE}" == "RDS" ]
        then
            if [ "${RESOURCE}" == "RDSUtil" ]
            then
                RESOURCE_URL=${SERVICE_NAME}"/rds"
            else
                RESOURCE_URL=${SERVICE_NAME}"/rds/"${_RESOURCE_l}
            fi
        elif [ "${SERVICE}" == "VPC" ]
        then
            if [ "${RESOURCE}" == "VPCUtil" ]
            then
                RESOURCE_URL=${SERVICE_NAME}"/vpc"
            elif [ "${_RESOURCE_l}" == "vpngateway" ]
            then
                RESOURCE_URL=${SERVICE_NAME}"/vpc/vgw"
            elif [ "${_RESOURCE_l}" == "customergateway" ]
            then
                RESOURCE_URL=${SERVICE_NAME}"/vpc/cgw"
            elif [ "${_RESOURCE_l}" == "internetgateway" ]
            then
                RESOURCE_URL=${SERVICE_NAME}"/vpc/igw"
            else
                RESOURCE_URL=${SERVICE_NAME}"/vpc/"${_RESOURCE_l}
            fi
        elif [ "${SERVICE}" == "EC2" ]
        then
            if [ "${RESOURCE}" == "EC2Util" ]
            then
                RESOURCE_URL=${SERVICE_NAME}"/ec2"
            elif [ "${RESOURCE}" == "EIP" ]
            then
                RESOURCE_URL=${SERVICE_NAME}"/ec2/elasticip"
            else
                RESOURCE_URL=${SERVICE_NAME}"/ec2/"${_RESOURCE_l}
            fi
        elif [ "${SERVICE}" == "ELB" ]
        then
            if [ "${RESOURCE}" == "ELBUtil" ]
            then
                RESOURCE_URL=${SERVICE_NAME}"/elb"
            else
                RESOURCE_URL=${SERVICE_NAME}"/elb/"${_RESOURCE_l}
            fi
        elif [ "${SERVICE}" == "IAM" ]
        then
            if [ "${RESOURCE}" == "IAMUtil" ]
            then
                RESOURCE_URL=${SERVICE_NAME}"/iam"
            else
                RESOURCE_URL=${SERVICE_NAME}"/iam/"${_RESOURCE_l}
            fi
        elif [ "${_RESOURCE_l}" == "ec2" -o "${_RESOURCE_l}" == "elb" -o "${_RESOURCE_l}" == "iam" -o "${_RESOURCE_l}" == "vpc" ]
        then
            RESOURCE_URL=${SERVICE_NAME}
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
        API_TYPE="Marathon"
        api_type="marathon"
    fi

    echo
    echo "#......................................................."
    echo " api_type : "${api_type}
    echo "#......................................................."
    echo "# SRC_FILE: "${__CUR_DIR}/${__CUR_FILE}
    echo "# TGT_DIR_SERVICE : "${__TGT_DIR_SERVICE}
    echo "# TGT_DIR_TEST    : "${__TGT_DIR_TEST}
    echo "# SERVICE         : "${SERVICE}
    echo "# RESOURCE        : "${RESOURCE}
    echo "#-------------------------------------------------------"
    echo "# SERVICE_URL     : "${SERVICE_URL}
    echo "# RESOURCE_URL    : "${RESOURCE_URL}
    echo "# SERVICE_NAME    : "${SERVICE_NAME}
    echo "# RESOURCE_NAME   : "${_RESOURCE_l}
    echo "#......................................................."

    # if [ ! -d ${__TGT_DIR_SERVICE} ]
    # then
    #     mkdir -p ${__TGT_DIR_SERVICE}
    # fi

    # if [ ! -d ${__TGT_DIR_TEST} ]
    # then
    #     mkdir -p ${__TGT_DIR_TEST}
    # fi

 

    echo "append api..."
    _PUBLIC_API_LIST=""
    _PUBLIC_PARSER_LIST=""

    _LAST_API=""
    _NUM_API=""

    FOUND=`echo ${__TGT_DIR_SERVICE} | grep "/${_RESOURCE_l}" | wc -l`
    if [ ${FOUND} -eq 1 ]
    then
        OUTPUT_FILE=${__TGT_DIR_SERVICE}
    else
        OUTPUT_FILE=${__TGT_DIR_SERVICE}_${_RESOURCE_l}
    fi

    echo "define(['ApiRequestDefs'], function( ApiRequestDefs ){" > ${OUTPUT_FILE}.js
    echo -e "\tvar Apis = {" >> ${OUTPUT_FILE}.js

    #// loop by API_NAME ////////////////////////////////////////////////////////////////////
    for (( j = 1 ; j <= ${#API_NAME[@]} ; j++ ))
    do

        _NUM_API=${#API_NAME[@]}

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
        # if [ "${_CUR_API}" == "public"  ]
        # then
        #     _CUR_API="Public"
        # fi

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
                _PARAM_LIST="'${CUR_PARAM[$k]}'"
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
                _PARAM_LIST="${_PARAM_LIST}, '${CUR_PARAM[$k]}'"
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
        if [ "${__TYPE}" == "aws" ]
        then
        #api in aws that Start with Describe/Get/List need resolve
            NEED_RESOLVE=`echo "${_CUR_API}"  | grep -E "^Describe|^Get|^List" | wc -l `
            if [ ${NEED_RESOLVE} -eq 0  ]
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
        if [ "${_CUR_API}" == "def" ]
        then
            continue
        elif [ "${_CUR_API}" == "images" ]
        then
            _API_NAME="'marathon_${_CUR_API}'"
        else
            _API_NAME="'marathon_${_RESOURCE_l}_${_CUR_API}'"
        fi


        _URL="'/${RESOURCE_URL}/'"
        _API_NAME=`echo ${_API_NAME} | awk '{printf "%-35s", $0}'`
        echo -e "\t\t${_API_NAME} : { type:'${api_type}', url:${_URL},\tmethod:'${_CUR_API}',\tparams:[${_PARAM_LIST}]   }," >> ${OUTPUT_FILE}.js

        _LAST_API=${_CUR_API}

    done

    echo -e "\t}" >> ${OUTPUT_FILE}.js
    echo -e "" >> ${OUTPUT_FILE}.js
    echo -e "\tfor ( var i in Apis ) {" >> ${OUTPUT_FILE}.js
    echo -e "\t\t/* env:dev */" >> ${OUTPUT_FILE}.js
    echo -e "\t\tif (ApiRequestDefs.Defs[ i ]){" >> ${OUTPUT_FILE}.js
    echo -e "\t\t\tconsole.warn('api duplicate: ' + i);" >> ${OUTPUT_FILE}.js
    echo -e "\t\t}" >> ${OUTPUT_FILE}.js
    echo -e "\t\t/* env:dev:end */" >> ${OUTPUT_FILE}.js
    echo -e "\t\tApiRequestDefs.Defs[ i ] = Apis[ i ];" >> ${OUTPUT_FILE}.js
    echo -e "\t}" >> ${OUTPUT_FILE}.js
    echo -e "" >> ${OUTPUT_FILE}.js
    echo -e "});" >> ${OUTPUT_FILE}.js

    echo

    return


}



#===================================================================
# Scan python file for handler/marathon
#===================================================================
function fn_scan_handler_marathon() {
#process single file

    CUR_DIR=$1
    CUR_FILE=$2

    echo "########################################################"
    echo "#Processing "`echo ${CUR_DIR} | awk 'BEGIN{FS="[/]"}{print $(NF) }' `" - "${CUR_FILE}
    echo "########################################################"

    TGT_DIR=${TGT_BASE_DIR}/"service"/${CUR_FILE/Handler/}      #remove Handler
    TGT_DIR=${TGT_DIR/.py/}                                     #remove .py
    TGT_DIR=${TGT_DIR,,}                                        #tolower

    fn_generate_coffee "marathon" "${CUR_DIR}" "${CUR_FILE}" "${TGT_DIR}"

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
        if [ "${SRC_DIR[$i]}" == "Marathon" ]
        then
            fn_scan_handler_marathon "${CUR_SRC_DIR}" "${LINE}"
        fi
    done
done

##############################################################

### merge rds and vpc ####
echo "merge marathon"
LINE_LST=""

if [ `ls ${TGT_BASE_DIR}/service/*.js | wc -l` -gt 0 ]
then
    rm -rf ${TGT_BASE_DIR}/service/marathon.tmp
    for LINE in `ls ${TGT_BASE_DIR}/service/*.js| grep -v app`
    do
        if [ "${FIRST_FILE}" == "" ]
        then
            FIRST_FILE=${LINE}
        fi
        cat ${LINE} | grep "method:" >> ${TGT_BASE_DIR}/service/marathon.tmp
    done
    #cat ${TGT_BASE_DIR}/service/.tmp
    sed '/app_list_version/r out.tmp/service/marathon.tmp' ${TGT_BASE_DIR}/service/app.js > ${TGT_BASE_DIR}/service/marathon.rlt
    rm -rf ${TGT_BASE_DIR}/service/*.js
    mv ${TGT_BASE_DIR}/service/marathon.rlt ${TGT_BASE_DIR}/service/marathon.js
    rm -rf ${TGT_BASE_DIR}/service/*.tmp
fi

echo "##############################################################"
echo "generate ApiBundle.js"
echo "define([ ${_DEFINE_} ],function(){})" > ${TGT_BASE_DIR}/ApiBundle.js
echo
echo "##############################################################"
echo "copy new api define to target dir"
\cp ${TGT_BASE_DIR}/service/marathon.js ${SH_BASE_DIR}/../../src/api/define/marathon.js
cd ${SH_BASE_DIR}/../../
echo "current dir: `pwd`"
echo
echo "Use 'git status' or 'git diff' to see the change"
echo
echo "Done"
echo




