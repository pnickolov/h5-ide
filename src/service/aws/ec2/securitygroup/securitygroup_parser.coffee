#*************************************************************************************
#* Filename     : securitygroup_parser.coffee
#* Creator      : gen_service.sh
#* Create date  : 2013-05-25 14:06:14
#* Description  : parser return data of securitygroup
# ************************************************************************************
# (c)Copyright 2012 Madeiracloud  All Rights Reserved
# ************************************************************************************

define [ 'securitygroup_vo', 'result_vo', 'constant' ], ( securitygroup_vo, result_vo, constant ) ->


    #///////////////// Parser for CreateSecurityGroup return  /////////////////
    #private (parser CreateSecurityGroup return)
    parserCreateSecurityGroupReturn = ( result, return_code, param ) ->

        #1.resolve return_code
        result_vo.aws_result = result_vo.processAWSReturnHandler result, return_code, param

        #2.return vo
        result_vo.aws_result

    # end of parserCreateSecurityGroupReturn


    #///////////////// Parser for DeleteSecurityGroup return  /////////////////
    #private (parser DeleteSecurityGroup return)
    parserDeleteSecurityGroupReturn = ( result, return_code, param ) ->

        #1.resolve return_code
        result_vo.aws_result = result_vo.processAWSReturnHandler result, return_code, param

        #2.return vo
        result_vo.aws_result

    # end of parserDeleteSecurityGroupReturn


    #///////////////// Parser for AuthorizeSecurityGroupIngress return  /////////////////
    #private (parser AuthorizeSecurityGroupIngress return)
    parserAuthorizeSecurityGroupIngressReturn = ( result, return_code, param ) ->

        #1.resolve return_code
        result_vo.aws_result = result_vo.processAWSReturnHandler result, return_code, param

        #2.return vo
        result_vo.aws_result

    # end of parserAuthorizeSecurityGroupIngressReturn


    #///////////////// Parser for RevokeSecurityGroupIngress return  /////////////////
    #private (parser RevokeSecurityGroupIngress return)
    parserRevokeSecurityGroupIngressReturn = ( result, return_code, param ) ->

        #1.resolve return_code
        result_vo.aws_result = result_vo.processAWSReturnHandler result, return_code, param

        #2.return vo
        result_vo.aws_result

    # end of parserRevokeSecurityGroupIngressReturn


    #///////////////// Parser for DescribeSecurityGroups return (need resolve) /////////////////
    #private (resolve result to vo )
    resolveDescribeSecurityGroupsResult = ( result ) ->
        #resolve result
        #TO-DO

        #return vo
        #TO-DO

    #private (parser DescribeSecurityGroups return)
    parserDescribeSecurityGroupsReturn = ( result, return_code, param ) ->

        #1.resolve return_code
        result_vo.aws_result = result_vo.processAWSReturnHandler result, return_code, param

        #2.resolve return_data when return_code is E_OK
        if return_code == constant.RETURN_CODE.E_OK && !result_vo.aws_result.is_error

            resolved_data = resolveDescribeSecurityGroupsResult result

            result_vo.aws_result.resolved_data = resolved_data


        #3.return vo
        result_vo.aws_result

    # end of parserDescribeSecurityGroupsReturn


    #############################################################
    #public
    parserCreateSecurityGroupReturn          : parserCreateSecurityGroupReturn
    parserDeleteSecurityGroupReturn          : parserDeleteSecurityGroupReturn
    parserAuthorizeSecurityGroupIngressReturn : parserAuthorizeSecurityGroupIngressReturn
    parserRevokeSecurityGroupIngressReturn   : parserRevokeSecurityGroupIngressReturn
    parserDescribeSecurityGroupsReturn       : parserDescribeSecurityGroupsReturn

