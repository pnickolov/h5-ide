#*************************************************************************************
#* Filename     : ec2_parser.coffee
#* Creator      : gen_service.sh
#* Create date  : 2013-05-25 14:06:09
#* Description  : parser return data of ec2
# ************************************************************************************
# (c)Copyright 2012 Madeiracloud  All Rights Reserved
# ************************************************************************************

define [ 'ec2_vo', 'result_vo', 'constant' ], ( ec2_vo, result_vo, constant ) ->


    #///////////////// Parser for CreateTags return  /////////////////
    #private (parser CreateTags return)
    parserCreateTagsReturn = ( result, return_code, param ) ->

        #1.resolve return_code
        result_vo.aws_result = result_vo.processAWSReturnHandler result, return_code, param

        #2.return vo
        result_vo.aws_result

    # end of parserCreateTagsReturn


    #///////////////// Parser for DeleteTags return  /////////////////
    #private (parser DeleteTags return)
    parserDeleteTagsReturn = ( result, return_code, param ) ->

        #1.resolve return_code
        result_vo.aws_result = result_vo.processAWSReturnHandler result, return_code, param

        #2.return vo
        result_vo.aws_result

    # end of parserDeleteTagsReturn


    #///////////////// Parser for DescribeTags return (need resolve) /////////////////
    #private (resolve result to vo )
    resolveDescribeTagsResult = ( result ) ->
        #resolve result

        #return vo
        ($.xml2json ($.parseXML result[1])).DescribeTagsResponse.tagSet

    #private (parser DescribeTags return)
    parserDescribeTagsReturn = ( result, return_code, param ) ->

        #1.resolve return_code
        result_vo.aws_result = result_vo.processAWSReturnHandler result, return_code, param

        #2.resolve return_data when return_code is E_OK
        if return_code == constant.RETURN_CODE.E_OK && !result_vo.aws_result.is_error

            resolved_data = resolveDescribeTagsResult result

            result_vo.aws_result.resolved_data = resolved_data


        #3.return vo
        result_vo.aws_result

    # end of parserDescribeTagsReturn


    #///////////////// Parser for DescribeRegions return (need resolve) /////////////////
    #private (resolve result to vo )
    resolveDescribeRegionsResult = ( result ) ->
        #resolve result

        #return vo
        ($.xml2json ($.parseXML result[1])).DescribeRegionsResponse.regionInfo

    #private (parser DescribeRegions return)
    parserDescribeRegionsReturn = ( result, return_code, param ) ->

        #1.resolve return_code
        result_vo.aws_result = result_vo.processAWSReturnHandler result, return_code, param

        #2.resolve return_data when return_code is E_OK
        if return_code == constant.RETURN_CODE.E_OK && !result_vo.aws_result.is_error

            resolved_data = resolveDescribeRegionsResult result

            result_vo.aws_result.resolved_data = resolved_data


        #3.return vo
        result_vo.aws_result

    # end of parserDescribeRegionsReturn


    #///////////////// Parser for DescribeAvailabilityZones return (need resolve) /////////////////
    #private (resolve result to vo )
    resolveDescribeAvailabilityZonesResult = ( result ) ->
        #resolve result

        #return vo
        ($.xml2json ($.parseXML result[1])).DescribeAvailabilityZonesResponse.availabilityZoneInfo

    #private (parser DescribeAvailabilityZones return)
    parserDescribeAvailabilityZonesReturn = ( result, return_code, param ) ->

        #1.resolve return_code
        result_vo.aws_result = result_vo.processAWSReturnHandler result, return_code, param

        #2.resolve return_data when return_code is E_OK
        if return_code == constant.RETURN_CODE.E_OK && !result_vo.aws_result.is_error

            resolved_data = resolveDescribeAvailabilityZonesResult result

            result_vo.aws_result.resolved_data = resolved_data


        #3.return vo
        result_vo.aws_result

    # end of parserDescribeAvailabilityZonesReturn


    #############################################################
    #public
    parserCreateTagsReturn                   : parserCreateTagsReturn
    parserDeleteTagsReturn                   : parserDeleteTagsReturn
    parserDescribeTagsReturn                 : parserDescribeTagsReturn
    parserDescribeRegionsReturn              : parserDescribeRegionsReturn
    parserDescribeAvailabilityZonesReturn    : parserDescribeAvailabilityZonesReturn
    resolveDescribeAvailabilityZonesResult   : resolveDescribeAvailabilityZonesResult
    resolveDescribeRegionsResult             : resolveDescribeRegionsResult