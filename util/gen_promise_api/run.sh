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
        API_TYPE="Forge"
        api_type="forge"
    fi

    echo
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

        #gen prefix
        if [ "${SERVICE}" == "RDS" ]
        then
            case "${_RESOURCE_l}" in
                ###RDS###
                # "rds" )              RESOURCE_NAME_SHORT=${_RESOURCE_l/rds/rds};;
                "instance" )         RESOURCE_NAME_SHORT=${_RESOURCE_l/instance/rds_ins};;
                "reservedinstance" ) RESOURCE_NAME_SHORT=${_RESOURCE_l/reservedinstance/rds_revd_ins};;
                "optiongroup" )      RESOURCE_NAME_SHORT=${_RESOURCE_l/optiongroup/rds_og};;
                "parametergroup" )   RESOURCE_NAME_SHORT=${_RESOURCE_l/parametergroup/rds_pg};;
                "securitygroup" )    RESOURCE_NAME_SHORT=${_RESOURCE_l/securitygroup/rds_sg};;
                "snapshot" )         RESOURCE_NAME_SHORT=${_RESOURCE_l/snapshot/rds_snap};;
                "subnetgroup" )      RESOURCE_NAME_SHORT=${_RESOURCE_l/subnetgroup/rds_subgrp};;
                *)                   RESOURCE_NAME_SHORT=${_RESOURCE_l};
            esac
        else
            case "${_RESOURCE_l}" in
                ###EC2###
                # "ec2" )             RESOURCE_NAME_SHORT=${_RESOURCE_l/ec2/ec2};;
                # "eip" )             RESOURCE_NAME_SHORT=${_RESOURCE_l/eip/eip};;
                # "ami" )             RESOURCE_NAME_SHORT=${_RESOURCE_l/ami/ami};;
                # "ebs" )             RESOURCE_NAME_SHORT=${_RESOURCE_l/ebs/ebs};;
                "keypair" )         RESOURCE_NAME_SHORT=${_RESOURCE_l/keypair/kp};;
                "instance" )        RESOURCE_NAME_SHORT=${_RESOURCE_l/instance/ins};;
                "securitygroup" )   RESOURCE_NAME_SHORT=${_RESOURCE_l/securitygroup/sg};;
                "placementgroup" )  RESOURCE_NAME_SHORT=${_RESOURCE_l/placementgroup/pg};;
                ###ELB###
                # "elb" )             RESOURCE_NAME_SHORT=${_RESOURCE_l/elb/elb};;
                # "iam" )             RESOURCE_NAME_SHORT=${_RESOURCE_l/iam/iam};;
                ###VPC###
                # "vpc" )             RESOURCE_NAME_SHORT=${_RESOURCE_l/vpc/vpc};;
                # "dhcp" )            RESOURCE_NAME_SHORT=${_RESOURCE_l/dhcp/dhcp};;
                # "vpn" )             RESOURCE_NAME_SHORT=${_RESOURCE_l/vpn/vpn};;
                # "acl" )             RESOURCE_NAME_SHORT=${_RESOURCE_l/acl/acl};;
                # "eni" )             RESOURCE_NAME_SHORT=${_RESOURCE_l/eni/eni};;
                # "subnet" )          RESOURCE_NAME_SHORT=${_RESOURCE_l/subnet/subnet};;
                "routetable" )      RESOURCE_NAME_SHORT=${_RESOURCE_l/routetable/rtb};;
                "internetgateway" ) RESOURCE_NAME_SHORT=${_RESOURCE_l/internetgateway/igw};;
                "customergateway" ) RESOURCE_NAME_SHORT=${_RESOURCE_l/customergateway/cgw};;
                "vpngateway" )      RESOURCE_NAME_SHORT=${_RESOURCE_l/vpngateway/vgw};;
                ###ASG###
                "autoscaling" )     RESOURCE_NAME_SHORT=${_RESOURCE_l/autoscaling/asl};;
                "cloudwatch" )      RESOURCE_NAME_SHORT=${_RESOURCE_l/cloudwatch/clw};;
                # "sns" )             RESOURCE_NAME_SHORT=${_RESOURCE_l/sns/sns};;
                ###OpsWork###
                "opsworks" )        RESOURCE_NAME_SHORT=${_RESOURCE_l/opsworks/ow};;
                *)                  RESOURCE_NAME_SHORT=${_RESOURCE_l};
            esac
        fi

        # echo "_RESOURCE_l: ${_RESOURCE_l}"
        # echo "RESOURCE_NAME_SHORT: ${RESOURCE_NAME_SHORT}"


        #1.append api ( ${_CUR_API} ) to ${_RESOURCE_l}_service.coffee
        if [ "${__TYPE}" == "aws" ]
        then
            if [ "${RESOURCE}" == "EBS" ]
            then
                FOUND_VOL=`echo ${_CUR_API} | grep "Volume" | wc -l`
                if [ ${FOUND_VOL} -eq 1 ]
                then
                    _API_NAME="'${RESOURCE_NAME_SHORT}_${_CUR_API}'"
                    _URL="'/${RESOURCE_URL}/volume/'"
                else
                    _API_NAME="'${RESOURCE_NAME_SHORT}_${_CUR_API}'"
                    _URL="'/${RESOURCE_URL}/snapshot/'"
                fi
            else
                _API_NAME="'${RESOURCE_NAME_SHORT}_${_CUR_API}'"
                _URL="'/${RESOURCE_URL}/'"
            fi
            _API_NAME=`echo ${_API_NAME} | awk '{printf "%-40s", $0}'`
        elif [ "${__TYPE}" == "awsutil" ]
        then
            _API_NAME="'aws_${_CUR_API}'"
            _URL="'/${RESOURCE_URL}/'"
            _API_NAME=`echo ${_API_NAME} | awk '{printf "%-20s", $0}'`
        else
            if [ "${_RESOURCE_l}" == "user" ]
            then
                _API_NAME="'${_RESOURCE_l/user/account}_${_CUR_API}'"
                _URL="'/account/'"
            else
                _API_NAME="'${_RESOURCE_l}_${_CUR_API}'"
                _URL="'/${RESOURCE_URL}/'"
            fi
            _API_NAME=`echo ${_API_NAME} | awk '{printf "%-25s", $0}'`
        fi
        
        echo -e "\t\t${_API_NAME} : { url:${_URL},\tmethod:'${_CUR_API}',\tparams:[${_PARAM_LIST}]   }," >> ${OUTPUT_FILE}.js
    

        _LAST_API=${_CUR_API}

    done

    echo -e "\t}" >> ${OUTPUT_FILE}.js
    echo -e "" >> ${OUTPUT_FILE}.js
    echo -e "\tfor ( var i in Apis ) {" >> ${OUTPUT_FILE}.js
    echo -e "\t\tApiRequestDefs.Defs[ i ] = Apis[ i ];" >> ${OUTPUT_FILE}.js
    echo -e "\t}" >> ${OUTPUT_FILE}.js
    echo -e "" >> ${OUTPUT_FILE}.js
    echo -e "});" >> ${OUTPUT_FILE}.js


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
    # if [ "${CUR_FILE}" != "TokenHandler.py" -a "${CUR_FILE}" != "SessionHandler.py" ]
    # then
    #    return
    # fi

    echo "########################################################"
    echo "#Processing "`echo ${CUR_DIR} | awk 'BEGIN{FS="[/]"}{print $(NF) }' `" - "${CUR_FILE}
    echo "########################################################"

    TGT_DIR=${TGT_BASE_DIR}/"service"/${CUR_FILE/Handler/}      #remove Handler
    TGT_DIR=${TGT_DIR/.py/}                                     #remove .py
    TGT_DIR=${TGT_DIR,,}                                        #tolower

    #create subdir in out.tmp
    #mkdir -p ${TGT_DIR}                             #create out.tmp/service/

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

    # SERVICE: AWSUtil.py
    # SERVICE: CloudWatch
    # SERVICE: EC2
    # SERVICE: ELB
    # SERVICE: IAM
    # SERVICE: OpsWorks
    # SERVICE: RDS
    # SERVICE: SDB
    # SERVICE: SNS
    # SERVICE: VPC
    # SERVICE: AutoScaling


    # if [ "${SERVICE}" != "VPC" ]
    # then
    #     return
    # fi


    #service
    echo
    echo "#======================================================="
    echo "#  SERVICE: ${SERVICE}"
    echo "#======================================================="

    mkdir -p ${TGT_BASE_DIR}/"service"/aws/

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
        #mkdir -p ${TGT_DIR}                             #create out.tmp/service/

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
            TGT_DIR=${TGT_BASE_DIR}/"service"/aws/${SERVICE,,}    #lower

            #create subdir in out.tmp
            #mkdir -p ${TGT_DIR}                             #create out.tmp/service/

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

##############################################################

### merge rds and vpc ####

echo "merge ec2"
LINE_LST=""
if [ -f ${TGT_BASE_DIR}/service/aws/ec2.js ]
then
    rm -rf ${TGT_BASE_DIR}/service/aws/ec2.tmp
    for LINE in `ls ${TGT_BASE_DIR}/service/aws/ec2_*.js`
    do
        cat ${LINE} | grep "method:" >> ${TGT_BASE_DIR}/service/aws/ec2_.tmp
    done
    #cat ${TGT_BASE_DIR}/service/aws/ec2.tmp
    sed '/ec2_DescribeAvailabilityZones/r out.tmp/service/aws/ec2_.tmp' ${TGT_BASE_DIR}/service/aws/ec2.js > ${TGT_BASE_DIR}/service/aws/ec22.js
    rm -rf ${TGT_BASE_DIR}/service/aws/ec2_*.*
    mv ${TGT_BASE_DIR}/service/aws/ec22.js ${TGT_BASE_DIR}/service/aws/ec2.js
fi


echo "merge rds"
LINE_LST=""
if [ -f ${TGT_BASE_DIR}/service/aws/rds.js ]
then
    rm -rf ${TGT_BASE_DIR}/service/aws/rds.tmp
    for LINE in `ls ${TGT_BASE_DIR}/service/aws/rds_*.js`
    do
        cat ${LINE} | grep "method:" >> ${TGT_BASE_DIR}/service/aws/rds_.tmp
    done
    #cat ${TGT_BASE_DIR}/service/aws/rds.tmp
    sed '/rds_DescribeEvents/r out.tmp/service/aws/rds_.tmp' ${TGT_BASE_DIR}/service/aws/rds.js > ${TGT_BASE_DIR}/service/aws/rds2.js
    rm -rf ${TGT_BASE_DIR}/service/aws/rds_*.*
    mv ${TGT_BASE_DIR}/service/aws/rds2.js ${TGT_BASE_DIR}/service/aws/rds.js
fi

echo "merge vpc"
LINE_LST=""
if [ -f ${TGT_BASE_DIR}/service/aws/vpc.js ]
then
    rm -rf ${TGT_BASE_DIR}/service/aws/vpc.tmp
    for LINE in `ls ${TGT_BASE_DIR}/service/aws/vpc_*.js`
    do
        cat ${LINE} | grep "method:" >> ${TGT_BASE_DIR}/service/aws/vpc_.tmp
    done
    #cat ${TGT_BASE_DIR}/service/aws/vpc.tmp
    sed '/vpc_DescribeVpcAttribute/r out.tmp/service/aws/vpc_.tmp' ${TGT_BASE_DIR}/service/aws/vpc.js > ${TGT_BASE_DIR}/service/aws/vpc2.js
    rm -rf ${TGT_BASE_DIR}/service/aws/vpc_*.*
    mv ${TGT_BASE_DIR}/service/aws/vpc2.js ${TGT_BASE_DIR}/service/aws/vpc.js
fi

echo "merge forge"
LINE_LST=""

if [ `ls ${TGT_BASE_DIR}/service/*.js | wc -l` -gt 0 ]
then
    rm -rf ${TGT_BASE_DIR}/service/forge.tmp
    for LINE in `ls ${TGT_BASE_DIR}/service/*.js| grep -v session`
    do
        if [ "${FIRST_FILE}" == "" ]
        then
            FIRST_FILE=${LINE}
        fi
        cat ${LINE} | grep "method:" >> ${TGT_BASE_DIR}/service/forge.tmp
    done
    #cat ${TGT_BASE_DIR}/service/.tmp
    sed '/session_set_credential/r out.tmp/service/forge.tmp' ${TGT_BASE_DIR}/service/session.js > ${TGT_BASE_DIR}/service/forge.rlt
    rm -rf ${TGT_BASE_DIR}/service/*.js
    mv ${TGT_BASE_DIR}/service/forge.rlt ${TGT_BASE_DIR}/service/forge.js
    rm -rf ${TGT_BASE_DIR}/service/*.tmp
fi

##############################################################
echo 
echo "##############################################################"
_DEFINE_=""
if [ -d ${TGT_BASE_DIR}/service ]
then
    for LINE in `ls ${TGT_BASE_DIR}/service | grep -v aws`
    do
        if [ "${_DEFINE_}" == "" ]
        then
            _DEFINE_="'./define/${LINE/.js/}'"
        else
            _DEFINE_=${_DEFINE_}", './define/${LINE/.js/}'"
        fi
    done
fi
echo "--------------------------------------------"
if [ -d ${TGT_BASE_DIR}/service/aws ]
then
    for LINE in `ls ${TGT_BASE_DIR}/service/aws`
    do
        if [ "${_DEFINE_}" == "" ]
        then
            _DEFINE_="'./define/aws/${LINE/.js/}'"
        else
            _DEFINE_=${_DEFINE_}", './define/aws/${LINE/.js/}'"
        fi
    done
fi
echo "##############################################################"
echo "generate ApiBundle.js"
echo "define([ ${_DEFINE_} ],function(){})" > ${TGT_BASE_DIR}/ApiBundle.js
echo
echo "Done"
echo
