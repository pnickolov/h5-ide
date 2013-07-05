#*************************************************************************************
#* Filename     : routetable_parser.coffee
#* Creator      : gen_service.sh
#* Create date  : 2013-05-25 14:06:23
#* Description  : parser return data of routetable
# ************************************************************************************
# (c)Copyright 2012 Madeiracloud  All Rights Reserved
# ************************************************************************************

define [  'result_vo', 'constant' ], (result_vo, constant ) ->


    #///////////////// Parser for DescribeRouteTables return (need resolve) /////////////////
    #private (resolve result to vo )
    resolveDescribeRouteTablesResult = ( result ) ->
        #return
        ($.xml2json ($.parseXML result[1])).DescribeRouteTablesResponse.routeTableSet

    #private (parser DescribeRouteTables return)
    parserDescribeRouteTablesReturn = ( result, return_code, param ) ->

        #1.resolve return_code
        aws_result = result_vo.processAWSReturnHandler result, return_code, param

        #2.resolve return_data when return_code is E_OK
        if return_code == constant.RETURN_CODE.E_OK && !aws_result.is_error

            resolved_data = resolveDescribeRouteTablesResult result

            aws_result.resolved_data = resolved_data


        #3.return vo
        aws_result

    # end of parserDescribeRouteTablesReturn


    #############################################################
    #public
    parserDescribeRouteTablesReturn          : parserDescribeRouteTablesReturn
    resolveDescribeRouteTablesResult         : resolveDescribeRouteTablesResult
