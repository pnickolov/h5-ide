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

G_EVENT=""

###########################################################
# function
###########################################################


#===================================================================
# 1.format event constant
#===================================================================
format_event () {

    ___SERVICE=$1
    ___RESOURCE=$2
    ___API_NAME=$3

    G_EVENT=""

    if [ "${___SERVICE}" == "EC2" -o "${___SERVICE}" == "RDS" -o "${___SERVICE}" == "VPC" ]
    then
        G_EVENT=`echo ${___API_NAME} | awk -v service=${___SERVICE} -v resource=${___RESOURCE} -F ""  'BEGIN{printf "%s_%s", toupper(service), toupper(resource)}{for ( x=1; x<=NF; x++){if ($x==toupper($x)){printf "_%s", toupper($x)}else{printf toupper($x)}}}END{printf "\n"}' `
    else
        G_EVENT=`echo ${___API_NAME} | awk -v resource=${___RESOURCE} -F ""  'BEGIN{printf "%s_", toupper(resource)}{for ( x=1; x<=NF; x++){if ($x==toupper($x)){printf "_%s", toupper($x)}else{printf toupper($x)}}}END{printf "\n"}' `        
    fi

    G_EVENT=${G_EVENT/DESCRIBE/DESC}
    G_EVENT=${G_EVENT/_D_B_/_DB_}
    G_EVENT=${G_EVENT/INSTANCE/INS}
    G_EVENT=${G_EVENT/SECURITY_GROUP/SG}
    G_EVENT=${G_EVENT/SECURITYGROUP/SG}
    G_EVENT=${G_EVENT/SUBNETGROUP/SNTG}
    G_EVENT=${G_EVENT/LOAD_BALANCER/LB}
    G_EVENT=${G_EVENT/LOADBALANCER/ELB}
    G_EVENT=${G_EVENT/SUBNET/SNET}
    G_EVENT=${G_EVENT/AUTOSCALING/ASL}
    G_EVENT=${G_EVENT/AUTO_SCALING/ASL}
    G_EVENT=${G_EVENT/CLOUDWATCH/CW}
    G_EVENT=${G_EVENT/PLACEMENTGROUP/PG}
    G_EVENT=${G_EVENT/SNAPSHOT/SS}
    G_EVENT=${G_EVENT/VOLUME/VOL}
    G_EVENT=${G_EVENT/KEYPAIR/KP}
    G_EVENT=${G_EVENT/OPTIONGROUP/OG}
    G_EVENT=${G_EVENT/PARAMETERGROUP/PG}
    G_EVENT=${G_EVENT/PLACEMENT/PLA}    
    G_EVENT=${G_EVENT/CUSTOMERGATEWAY/CGW}
    G_EVENT=${G_EVENT/INTERNETGATEWAY/IGW}
    G_EVENT=${G_EVENT/ROUTETABLE/RT}
    G_EVENT=${G_EVENT/VPNGATEWAY/VGW}
    G_EVENT=${G_EVENT/RESERVEDDBINSTANCE/RDBINSTANCE}
    G_EVENT=${G_EVENT/GROUP/GRP}
    G_EVENT=${G_EVENT/OPTION/OPT}
    G_EVENT=${G_EVENT/DEFAULT/DFT}
    G_EVENT=${G_EVENT/PARAMETER/PARAM}
    G_EVENT=${G_EVENT/VERSION/VER}
    G_EVENT=${G_EVENT/ENGINE/ENG}
    G_EVENT=${G_EVENT/RESERVED/RSVD}
    G_EVENT=${G_EVENT/LIST/LST}
    G_EVENT=${G_EVENT/ATTRIBUTE/ATTR}
    G_EVENT=${G_EVENT/SUBSCRIPTION/SUBSCR}
    G_EVENT=${G_EVENT/CUSTOMER/CUST}
    G_EVENT=${G_EVENT/GATEWAY/GW}
    G_EVENT=${G_EVENT/INTERFACE/IF}
    G_EVENT=${G_EVENT/INTERNET/INET}
    G_EVENT=${G_EVENT/ROUTE/RT}
    G_EVENT=${G_EVENT/TABLE/TBL}
    G_EVENT=${G_EVENT/CONNECTION/CONN}
    G_EVENT=${G_EVENT/METADATA/MDATA}
    G_EVENT=${G_EVENT/ORDERABLE/ORD} 
    G_EVENT=${G_EVENT/HEALTH/HLT} 
    G_EVENT=${G_EVENT/TYPE/TYP} 
    G_EVENT=${G_EVENT/ALARM/ALM} 
    G_EVENT=${G_EVENT/STATISTIC/STAT}
    G_EVENT=${G_EVENT/HISTORY/HIST}
    G_EVENT=${G_EVENT/NOTIFICATION/NTF}
    G_EVENT=${G_EVENT/CONFIGURATION/CONF}
    G_EVENT=${G_EVENT/COLLECTION/COLL}
    G_EVENT=${G_EVENT/ADJUSTMENT/ADJT}
    G_EVENT=${G_EVENT/PROCESS/PRC}
    G_EVENT=${G_EVENT/SCHEDULED/SCHD}
    G_EVENT=${G_EVENT/ACTIVITIE/ACTI}
    G_EVENT=${G_EVENT/ACTION/ACT}
    G_EVENT=${G_EVENT/AUTHORIZE/AUTH}
    G_EVENT=${G_EVENT/POLICY/PCY}    
    G_EVENT=${G_EVENT/NETWORK/NET}    
    G_EVENT=${G_EVENT/ADDRESS/ADDR}    
    G_EVENT=${G_EVENT/PASSWORD/PWD}    
    G_EVENT=${G_EVENT/POLICIES/PCYS}  
}


#===================================================================
# 2.Resolve api and param in python file, 2.generate coffee file
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
    echo "1.generate service/model.coffee (head)"
    sed -e ":a;N;$ s/@@resource-name/${_RESOURCE_l}/g;ba" ${TMPL_BASE_DIR}/service/model.coffee.head \
    | sed -e ":a;N;$ s/@@create-date/`date "+%Y-%m-%d %H:%M:%S"`/g;ba" \
    | sed -e ":a;N;$ s/@@RESOURCE-NAME/${_RESOURCE_u}/g;ba" \
    | sed -e ":a;N;$ s/@@api-type/${api_type}/g;ba" \
    > ${__TGT_DIR_SERVICE}/${_RESOURCE_l}_model.coffee


    _PUBLIC_API_LIST=""
    _PUBLIC_PARSER_LIST=""


    echo "2.append api invoke to ${_RESOURCE_l}_model.coffee"
    _LAST_API=""
    _NUM_API=""
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

        if [ "${__TYPE}" == "aws"  ]
        then
            #echo "format_event ${SERVICE} ${_RESOURCE} ${_CUR_API}"
            format_event ${SERVICE} ${_RESOURCE} ${_CUR_API}
        else
            #echo "format_event '' ${_RESOURCE_l} ${_CUR_API}"
            format_event "" ${_RESOURCE_l} ${_CUR_API}
        fi
        EVENT=${G_EVENT}"_RETURN"
        echo ${EVENT}
        #continue

        #echo "CUR_PARAM: "${CUR_PARAM[*]}
        #echo "_PARAM_DEF:"${_PARAM_DEF}
        #echo "_PARAM_LIST:"${_PARAM_LIST}

        #1.append api ( ${_CUR_API} ) to ${_RESOURCE_l}_model.coffee
        sed -e ":a;N;$ s/@@resource-name/${_RESOURCE_l}/g;ba" ${TMPL_BASE_DIR}/service/model.coffee.api \
        | sed -e ":a;N;$ s/@@api-name/${_CUR_API}/g;ba" \
        | sed -e ":a;N;$ s/@@api-type/${api_type}/g;ba" \
        | sed -e ":a;N;$ s/@@origin/${_CUR_ORIGIN}/g;ba" \
        | sed -e ":a;N;$ s/@@param-def/${_PARAM_DEF}/g;ba" \
        | sed -e ":a;N;$ s/@@param-list/${_PARAM_LIST}/g;ba" \
        | sed -e ":a;N;$ s/@@EVENT-NAME/${EVENT}/g;ba" \
        | sed -e ":a;N;$ s/@@parser-func/parser${_FUNC}Return/g;ba" \
        >> ${__TGT_DIR_SERVICE}/${_RESOURCE_l}_model.coffee

        #public parser func
        _TMP=`echo "parser${_FUNC}Return" | awk '{printf "    %-40s : %s\n",$0,$0}'`
        _PUBLIC_PARSER_LIST=${_PUBLIC_PARSER_LIST}"\n"${_TMP}

        #public api func
        _TMP=`echo "${_CUR_API}" | awk '{printf "    %-28s : %s\n",$0,$0}'`
        _PUBLIC_API_LIST=${_PUBLIC_API_LIST}"\n"${_TMP}

        _LAST_API=${_CUR_API}

    done

    echo "3.append tail to ${_RESOURCE_l}_model.coffee"
    echo -e "\n    }\n\n    #############################################################\n\
    #private (instantiation)\n\
    ${_RESOURCE_l}_model = new ${_RESOURCE_u}Model()\n\
\n\
    #public (exposes methods)\n\
    ${_RESOURCE_l}_model\n\
"    >> ${__TGT_DIR_SERVICE}/${_RESOURCE_l}_model.coffee


    return


}



#===================================================================
# 3.Scan python file for handler/forge
#===================================================================
function fn_scan_handler_forge() {
#process single file

    #return

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

    TGT_DIR=${TGT_BASE_DIR}/"service"

    #create subdir in out.tmp
    mkdir -p ${TGT_DIR}                             #create out.tmp/service/

    fn_generate_coffee "forge" "${CUR_DIR}" "${CUR_FILE}" "${TGT_DIR}"

    return

}

#===================================================================
# 4.Scan python file for aws
#===================================================================
function fn_scan_aws() {

    #return

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
        TGT_DIR=${TGT_BASE_DIR}/"service"/aws
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
            TGT_DIR=${TGT_BASE_DIR}/"service"/aws/${SERVICE,,}

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
