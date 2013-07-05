#*************************************************************************************
#* Filename     : parametergroup_parser.coffee
#* Creator      : gen_service.sh
#* Create date  : 2013-05-25 14:06:19
#* Description  : parser return data of parametergroup
# ************************************************************************************
# (c)Copyright 2012 Madeiracloud  All Rights Reserved
# ************************************************************************************

define [  'result_vo', 'constant' ], (result_vo, constant ) ->


    #///////////////// Parser for DescribeDBParameterGroups return (need resolve) /////////////////
    #private (resolve result to vo )
    resolveDescribeDBParameterGroupsResult = ( result ) ->
        #resolve result
        #TO-DO

        #return vo
        #TO-DO

    #private (parser DescribeDBParameterGroups return)
    parserDescribeDBParameterGroupsReturn = ( result, return_code, param ) ->

        #1.resolve return_code
        aws_result = result_vo.processAWSReturnHandler result, return_code, param

        #2.resolve return_data when return_code is E_OK
        if return_code == constant.RETURN_CODE.E_OK && !aws_result.is_error

            resolved_data = resolveDescribeDBParameterGroupsResult result

            aws_result.resolved_data = resolved_data


        #3.return vo
        aws_result

    # end of parserDescribeDBParameterGroupsReturn


    #///////////////// Parser for DescribeDBParameters return (need resolve) /////////////////
    #private (resolve result to vo )
    resolveDescribeDBParametersResult = ( result ) ->
        #resolve result
        #TO-DO

        #return vo
        #TO-DO

    #private (parser DescribeDBParameters return)
    parserDescribeDBParametersReturn = ( result, return_code, param ) ->

        #1.resolve return_code
        aws_result = result_vo.processAWSReturnHandler result, return_code, param

        #2.resolve return_data when return_code is E_OK
        if return_code == constant.RETURN_CODE.E_OK && !aws_result.is_error

            resolved_data = resolveDescribeDBParametersResult result

            aws_result.resolved_data = resolved_data


        #3.return vo
        aws_result

    # end of parserDescribeDBParametersReturn


    #############################################################
    #public
    parserDescribeDBParameterGroupsReturn    : parserDescribeDBParameterGroupsReturn
    parserDescribeDBParametersReturn         : parserDescribeDBParametersReturn

