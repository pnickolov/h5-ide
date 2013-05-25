#*************************************************************************************
#* Filename     : vpc_parser.coffee
#* Creator      : gen_service.sh
#* Create date  : 2013-05-25 14:06:23
#* Description  : parser return data of vpc
# ************************************************************************************
# (c)Copyright 2012 Madeiracloud  All Rights Reserved
# ************************************************************************************

define [ 'vpc_vo', 'result_vo', 'constant' ], ( vpc_vo, result_vo, constant ) ->


    #///////////////// Parser for DescribeVpcs return (need resolve) /////////////////
    #private (resolve result to vo )
    resolveDescribeVpcsResult = ( result ) ->
        #resolve result
        #TO-DO

        #return vo
        #TO-DO

    #private (parser DescribeVpcs return)
    parserDescribeVpcsReturn = ( result, return_code, param ) ->

        #1.resolve return_code
        result_vo.aws_result = result_vo.processAWSReturnHandler result, return_code, param

        #2.resolve return_data when return_code is E_OK
        if return_code == constant.RETURN_CODE.E_OK && !result_vo.aws_result.is_error

            resolved_data = resolveDescribeVpcsResult result

            result_vo.aws_result.resolved_data = resolved_data


        #3.return vo
        result_vo.aws_result

    # end of parserDescribeVpcsReturn


    #///////////////// Parser for DescribeAccountAttributes return (need resolve) /////////////////
    #private (resolve result to vo )
    resolveDescribeAccountAttributesResult = ( result ) ->
        #resolve result
        #TO-DO

        #return vo
        #TO-DO

    #private (parser DescribeAccountAttributes return)
    parserDescribeAccountAttributesReturn = ( result, return_code, param ) ->

        #1.resolve return_code
        result_vo.aws_result = result_vo.processAWSReturnHandler result, return_code, param

        #2.resolve return_data when return_code is E_OK
        if return_code == constant.RETURN_CODE.E_OK && !result_vo.aws_result.is_error

            resolved_data = resolveDescribeAccountAttributesResult result

            result_vo.aws_result.resolved_data = resolved_data


        #3.return vo
        result_vo.aws_result

    # end of parserDescribeAccountAttributesReturn


    #///////////////// Parser for DescribeVpcAttribute return (need resolve) /////////////////
    #private (resolve result to vo )
    resolveDescribeVpcAttributeResult = ( result ) ->
        #resolve result
        #TO-DO

        #return vo
        #TO-DO

    #private (parser DescribeVpcAttribute return)
    parserDescribeVpcAttributeReturn = ( result, return_code, param ) ->

        #1.resolve return_code
        result_vo.aws_result = result_vo.processAWSReturnHandler result, return_code, param

        #2.resolve return_data when return_code is E_OK
        if return_code == constant.RETURN_CODE.E_OK && !result_vo.aws_result.is_error

            resolved_data = resolveDescribeVpcAttributeResult result

            result_vo.aws_result.resolved_data = resolved_data


        #3.return vo
        result_vo.aws_result

    # end of parserDescribeVpcAttributeReturn


    #############################################################
    #public
    parserDescribeVpcsReturn                 : parserDescribeVpcsReturn
    parserDescribeAccountAttributesReturn    : parserDescribeAccountAttributesReturn
    parserDescribeVpcAttributeReturn         : parserDescribeVpcAttributeReturn

