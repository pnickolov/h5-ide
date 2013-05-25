#*************************************************************************************
#* Filename     : rds_parser.coffee
#* Creator      : gen_service.sh
#* Create date  : 2013-05-25 14:06:19
#* Description  : parser return data of rds
# ************************************************************************************
# (c)Copyright 2012 Madeiracloud  All Rights Reserved
# ************************************************************************************

define [ 'rds_vo', 'result_vo', 'constant' ], ( rds_vo, result_vo, constant ) ->


    #///////////////// Parser for DescribeDBEngineVersions return (need resolve) /////////////////
    #private (resolve result to vo )
    resolveDescribeDBEngineVersionsResult = ( result ) ->
        #resolve result
        #TO-DO

        #return vo
        #TO-DO

    #private (parser DescribeDBEngineVersions return)
    parserDescribeDBEngineVersionsReturn = ( result, return_code, param ) ->

        #1.resolve return_code
        result_vo.aws_result = result_vo.processAWSReturnHandler result, return_code, param

        #2.resolve return_data when return_code is E_OK
        if return_code == constant.RETURN_CODE.E_OK && !result_vo.aws_result.is_error

            resolved_data = resolveDescribeDBEngineVersionsResult result

            result_vo.aws_result.resolved_data = resolved_data


        #3.return vo
        result_vo.aws_result

    # end of parserDescribeDBEngineVersionsReturn


    #///////////////// Parser for DescribeOrderableDBInstanceOptions return (need resolve) /////////////////
    #private (resolve result to vo )
    resolveDescribeOrderableDBInstanceOptionsResult = ( result ) ->
        #resolve result
        #TO-DO

        #return vo
        #TO-DO

    #private (parser DescribeOrderableDBInstanceOptions return)
    parserDescribeOrderableDBInstanceOptionsReturn = ( result, return_code, param ) ->

        #1.resolve return_code
        result_vo.aws_result = result_vo.processAWSReturnHandler result, return_code, param

        #2.resolve return_data when return_code is E_OK
        if return_code == constant.RETURN_CODE.E_OK && !result_vo.aws_result.is_error

            resolved_data = resolveDescribeOrderableDBInstanceOptionsResult result

            result_vo.aws_result.resolved_data = resolved_data


        #3.return vo
        result_vo.aws_result

    # end of parserDescribeOrderableDBInstanceOptionsReturn


    #///////////////// Parser for DescribeEngineDefaultParameters return (need resolve) /////////////////
    #private (resolve result to vo )
    resolveDescribeEngineDefaultParametersResult = ( result ) ->
        #resolve result
        #TO-DO

        #return vo
        #TO-DO

    #private (parser DescribeEngineDefaultParameters return)
    parserDescribeEngineDefaultParametersReturn = ( result, return_code, param ) ->

        #1.resolve return_code
        result_vo.aws_result = result_vo.processAWSReturnHandler result, return_code, param

        #2.resolve return_data when return_code is E_OK
        if return_code == constant.RETURN_CODE.E_OK && !result_vo.aws_result.is_error

            resolved_data = resolveDescribeEngineDefaultParametersResult result

            result_vo.aws_result.resolved_data = resolved_data


        #3.return vo
        result_vo.aws_result

    # end of parserDescribeEngineDefaultParametersReturn


    #///////////////// Parser for DescribeEvents return (need resolve) /////////////////
    #private (resolve result to vo )
    resolveDescribeEventsResult = ( result ) ->
        #resolve result
        #TO-DO

        #return vo
        #TO-DO

    #private (parser DescribeEvents return)
    parserDescribeEventsReturn = ( result, return_code, param ) ->

        #1.resolve return_code
        result_vo.aws_result = result_vo.processAWSReturnHandler result, return_code, param

        #2.resolve return_data when return_code is E_OK
        if return_code == constant.RETURN_CODE.E_OK && !result_vo.aws_result.is_error

            resolved_data = resolveDescribeEventsResult result

            result_vo.aws_result.resolved_data = resolved_data


        #3.return vo
        result_vo.aws_result

    # end of parserDescribeEventsReturn


    #############################################################
    #public
    parserDescribeDBEngineVersionsReturn     : parserDescribeDBEngineVersionsReturn
    parserDescribeOrderableDBInstanceOptionsReturn : parserDescribeOrderableDBInstanceOptionsReturn
    parserDescribeEngineDefaultParametersReturn : parserDescribeEngineDefaultParametersReturn
    parserDescribeEventsReturn               : parserDescribeEventsReturn

