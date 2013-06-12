#*************************************************************************************
#* Filename     : optiongroup_parser.coffee
#* Creator      : gen_service.sh
#* Create date  : 2013-05-25 14:06:19
#* Description  : parser return data of optiongroup
# ************************************************************************************
# (c)Copyright 2012 Madeiracloud  All Rights Reserved
# ************************************************************************************

define [ 'optiongroup_vo', 'result_vo', 'constant' ], ( optiongroup_vo, result_vo, constant ) ->


    #///////////////// Parser for DescribeOptionGroupOptions return (need resolve) /////////////////
    #private (resolve result to vo )
    resolveDescribeOptionGroupOptionsResult = ( result ) ->
        #resolve result
        #TO-DO

        #return vo
        #TO-DO

    #private (parser DescribeOptionGroupOptions return)
    parserDescribeOptionGroupOptionsReturn = ( result, return_code, param ) ->

        #1.resolve return_code
        aws_result = result_vo.processAWSReturnHandler result, return_code, param

        #2.resolve return_data when return_code is E_OK
        if return_code == constant.RETURN_CODE.E_OK && !aws_result.is_error

            resolved_data = resolveDescribeOptionGroupOptionsResult result

            aws_result.resolved_data = resolved_data


        #3.return vo
        aws_result

    # end of parserDescribeOptionGroupOptionsReturn


    #///////////////// Parser for DescribeOptionGroups return (need resolve) /////////////////
    #private (resolve result to vo )
    resolveDescribeOptionGroupsResult = ( result ) ->
        #resolve result
        #TO-DO

        #return vo
        #TO-DO

    #private (parser DescribeOptionGroups return)
    parserDescribeOptionGroupsReturn = ( result, return_code, param ) ->

        #1.resolve return_code
        aws_result = result_vo.processAWSReturnHandler result, return_code, param

        #2.resolve return_data when return_code is E_OK
        if return_code == constant.RETURN_CODE.E_OK && !aws_result.is_error

            resolved_data = resolveDescribeOptionGroupsResult result

            aws_result.resolved_data = resolved_data


        #3.return vo
        aws_result

    # end of parserDescribeOptionGroupsReturn


    #############################################################
    #public
    parserDescribeOptionGroupOptionsReturn   : parserDescribeOptionGroupOptionsReturn
    parserDescribeOptionGroupsReturn         : parserDescribeOptionGroupsReturn

