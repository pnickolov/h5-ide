#*************************************************************************************
#* Filename     : vpc_parser.coffee
#* Creator      : gen_service.sh
#* Create date  : 2013-05-25 14:06:23
#* Description  : parser return data of vpc
# ************************************************************************************
# (c)Copyright 2012 Madeiracloud  All Rights Reserved
# ************************************************************************************

define [  'result_vo', 'constant' ], (result_vo, constant ) ->

    resolvedObjectToArray = ( objs ) ->

        if objs.constructor == Array

            for obj in objs

                obj = resolvedObjectToArray obj

        if objs.constructor == Object

            if $.isEmptyObject objs

                objs = null

            for key, value of objs

                if key == 'item' and value.constructor == Object

                    tmp = []

                    tmp.push resolvedObjectToArray value

                    objs[key] = tmp

                else if value.constructor == Object or value.constructor == Array

                    objs[key] = resolvedObjectToArray value

        objs

    #///////////////// Parser for DescribeVpcs return (need resolve) /////////////////
    #private (resolve result to vo )
    resolveDescribeVpcsResult = ( result ) ->
        #return

        result_set = ($.xml2json ($.parseXML result[1])).DescribeVpcsResponse.vpcSet

        result = resolvedObjectToArray result_set

        if result?.item?

            return result.item

        else

            return null


    #private (parser DescribeVpcs return)
    parserDescribeVpcsReturn = ( result, return_code, param ) ->

        #1.resolve return_code
        aws_result = result_vo.processAWSReturnHandler result, return_code, param

        #2.resolve return_data when return_code is E_OK
        if return_code == constant.RETURN_CODE.E_OK && !aws_result.is_error

            resolved_data = resolveDescribeVpcsResult result

            aws_result.resolved_data = resolved_data


        #3.return vo
        aws_result

    # end of parserDescribeVpcsReturn


    #///////////////// Parser for DescribeAccountAttributes return (need resolve) /////////////////
    #private (resolve result to vo )
    resolveDescribeAccountAttributesResult = ( result ) ->
        #resolve result
        #TO-DO

        #return vo
        res = {}

        if (result[1] instanceof Object)
            res[region] = ($.xml2json ($.parseXML node)).DescribeAccountAttributesResponse for region, node of result[1]
        else
            res = ($.xml2json ($.parseXML result[1])).DescribeAccountAttributesResponse

        res

    #private (parser DescribeAccountAttributes return)
    parserDescribeAccountAttributesReturn = ( result, return_code, param ) ->

        #1.resolve return_code
        aws_result = result_vo.processAWSReturnHandler result, return_code, param

        #2.resolve return_data when return_code is E_OK
        if return_code == constant.RETURN_CODE.E_OK && !aws_result.is_error

            resolved_data = resolveDescribeAccountAttributesResult result

            aws_result.resolved_data = resolved_data


        #3.return vo
        aws_result

    # end of parserDescribeAccountAttributesReturn


    #///////////////// Parser for DescribeVpcAttribute return (need resolve) /////////////////
    #private (resolve result to vo )
    resolveDescribeVpcAttributeResult = ( result ) ->
        #resolve result
        #TO-DO

        #return vo
        ($.xml2json ($.parseXML result[1])).DescribeVpcAttributeResponse


    #private (parser DescribeVpcAttribute return)
    parserDescribeVpcAttributeReturn = ( result, return_code, param ) ->

        #1.resolve return_code
        aws_result = result_vo.processAWSReturnHandler result, return_code, param

        #2.resolve return_data when return_code is E_OK
        if return_code == constant.RETURN_CODE.E_OK && !aws_result.is_error

            resolved_data = resolveDescribeVpcAttributeResult result

            aws_result.resolved_data = resolved_data


        #3.return vo
        aws_result

    # end of parserDescribeVpcAttributeReturn


    #############################################################
    #public
    parserDescribeVpcsReturn                 : parserDescribeVpcsReturn
    parserDescribeAccountAttributesReturn    : parserDescribeAccountAttributesReturn
    parserDescribeVpcAttributeReturn         : parserDescribeVpcAttributeReturn
    resolveDescribeVpcsResult                : resolveDescribeVpcsResult
