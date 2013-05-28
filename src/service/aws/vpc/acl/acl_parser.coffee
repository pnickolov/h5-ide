#*************************************************************************************
#* Filename     : acl_parser.coffee
#* Creator      : gen_service.sh
#* Create date  : 2013-05-25 14:06:21
#* Description  : parser return data of acl
# ************************************************************************************
# (c)Copyright 2012 Madeiracloud  All Rights Reserved
# ************************************************************************************

define [ 'acl_vo', 'result_vo', 'constant' ], ( acl_vo, result_vo, constant ) ->


    #///////////////// Parser for DescribeNetworkAcls return (need resolve) /////////////////
    #private (resolve result to vo )
    resolveDescribeNetworkAclsResult = ( result ) ->

        #return acl
        ($.xml2json ($.parseXML result[1])).DescribeNetworkAclsResponse.networkAclSet

    #private (parser DescribeNetworkAcls return)
    parserDescribeNetworkAclsReturn = ( result, return_code, param ) ->

        #1.resolve return_code
        result_vo.aws_result = result_vo.processAWSReturnHandler result, return_code, param

        #2.resolve return_data when return_code is E_OK
        if return_code == constant.RETURN_CODE.E_OK && !result_vo.aws_result.is_error

            resolved_data = resolveDescribeNetworkAclsResult result

            result_vo.aws_result.resolved_data = resolved_data


        #3.return vo
        result_vo.aws_result

    # end of parserDescribeNetworkAclsReturn


    #############################################################
    #public
    parserDescribeNetworkAclsReturn          : parserDescribeNetworkAclsReturn

