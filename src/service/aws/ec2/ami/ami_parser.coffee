#*************************************************************************************
#* Filename     : ami_parser.coffee
#* Creator      : gen_service.sh
#* Create date  : 2013-05-25 14:06:06
#* Description  : parser return data of ami
# ************************************************************************************
# (c)Copyright 2012 Madeiracloud  All Rights Reserved
# ************************************************************************************

define [ 'ami_vo', 'result_vo', 'constant' ], ( ami_vo, result_vo, constant ) ->


    #///////////////// Parser for CreateImage return  /////////////////
    #private (parser CreateImage return)
    parserCreateImageReturn = ( result, return_code, param ) ->

        #1.resolve return_code
        result_vo.aws_result = result_vo.processAWSReturnHandler result, return_code, param

        #2.return vo
        result_vo.aws_result

    # end of parserCreateImageReturn


    #///////////////// Parser for RegisterImage return  /////////////////
    #private (parser RegisterImage return)
    parserRegisterImageReturn = ( result, return_code, param ) ->

        #1.resolve return_code
        result_vo.aws_result = result_vo.processAWSReturnHandler result, return_code, param

        #2.return vo
        result_vo.aws_result

    # end of parserRegisterImageReturn


    #///////////////// Parser for DeregisterImage return  /////////////////
    #private (parser DeregisterImage return)
    parserDeregisterImageReturn = ( result, return_code, param ) ->

        #1.resolve return_code
        result_vo.aws_result = result_vo.processAWSReturnHandler result, return_code, param

        #2.return vo
        result_vo.aws_result

    # end of parserDeregisterImageReturn


    #///////////////// Parser for ModifyImageAttribute return  /////////////////
    #private (parser ModifyImageAttribute return)
    parserModifyImageAttributeReturn = ( result, return_code, param ) ->

        #1.resolve return_code
        result_vo.aws_result = result_vo.processAWSReturnHandler result, return_code, param

        #2.return vo
        result_vo.aws_result

    # end of parserModifyImageAttributeReturn


    #///////////////// Parser for ResetImageAttribute return  /////////////////
    #private (parser ResetImageAttribute return)
    parserResetImageAttributeReturn = ( result, return_code, param ) ->

        #1.resolve return_code
        result_vo.aws_result = result_vo.processAWSReturnHandler result, return_code, param

        #2.return vo
        result_vo.aws_result

    # end of parserResetImageAttributeReturn


    #///////////////// Parser for DescribeImageAttribute return (need resolve) /////////////////
    #private (resolve result to vo )
    resolveDescribeImageAttributeResult = ( result ) ->
        #resolve result

        #return vo
        ($.xml2json ($.parseXML result[1])).DescribeImageAttributeResponse

    #private (parser DescribeImageAttribute return)
    parserDescribeImageAttributeReturn = ( result, return_code, param ) ->

        #1.resolve return_code
        result_vo.aws_result = result_vo.processAWSReturnHandler result, return_code, param

        #2.resolve return_data when return_code is E_OK
        if return_code == constant.RETURN_CODE.E_OK && !result_vo.aws_result.is_error

            resolved_data = resolveDescribeImageAttributeResult result

            result_vo.aws_result.resolved_data = resolved_data


        #3.return vo
        result_vo.aws_result

    # end of parserDescribeImageAttributeReturn


    #///////////////// Parser for DescribeImages return (need resolve) /////////////////
    #private (resolve result to vo )
    resolveDescribeImagesResult = ( result ) ->
        #resolve result

        #return vo
        ($.xml2json ($.parseXML result[1])).DescribeImagesResponse.imagesSet

    #private (parser DescribeImages return)
    parserDescribeImagesReturn = ( result, return_code, param ) ->

        #1.resolve return_code
        result_vo.aws_result = result_vo.processAWSReturnHandler result, return_code, param

        #2.resolve return_data when return_code is E_OK
        if return_code == constant.RETURN_CODE.E_OK && !result_vo.aws_result.is_error

            resolved_data = resolveDescribeImagesResult result

            result_vo.aws_result.resolved_data = resolved_data


        #3.return vo
        result_vo.aws_result

    # end of parserDescribeImagesReturn


    #############################################################
    #public
    parserCreateImageReturn                  : parserCreateImageReturn
    parserRegisterImageReturn                : parserRegisterImageReturn
    parserDeregisterImageReturn              : parserDeregisterImageReturn
    parserModifyImageAttributeReturn         : parserModifyImageAttributeReturn
    parserResetImageAttributeReturn          : parserResetImageAttributeReturn
    parserDescribeImageAttributeReturn       : parserDescribeImageAttributeReturn
    parserDescribeImagesReturn               : parserDescribeImagesReturn
    resolveDescribeImagesResult              : resolveDescribeImagesResult

