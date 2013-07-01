#*************************************************************************************
#* Filename     : keypair_parser.coffee
#* Creator      : gen_service.sh
#* Create date  : 2013-05-25 14:06:13
#* Description  : parser return data of keypair
# ************************************************************************************
# (c)Copyright 2012 Madeiracloud  All Rights Reserved
# ************************************************************************************

define [ 'result_vo', 'constant' ], (result_vo, constant ) ->


    #///////////////// Parser for CreateKeyPair return  /////////////////
    #private (parser CreateKeyPair return)
    parserCreateKeyPairReturn = ( result, return_code, param ) ->

        #1.resolve return_code
        aws_result = result_vo.processAWSReturnHandler result, return_code, param

        #2.return vo
        aws_result

    # end of parserCreateKeyPairReturn


    #///////////////// Parser for DeleteKeyPair return  /////////////////
    #private (parser DeleteKeyPair return)
    parserDeleteKeyPairReturn = ( result, return_code, param ) ->

        #1.resolve return_code
        aws_result = result_vo.processAWSReturnHandler result, return_code, param

        #2.return vo
        aws_result

    # end of parserDeleteKeyPairReturn


    #///////////////// Parser for ImportKeyPair return  /////////////////
    #private (parser ImportKeyPair return)
    parserImportKeyPairReturn = ( result, return_code, param ) ->

        #1.resolve return_code
        aws_result = result_vo.processAWSReturnHandler result, return_code, param

        #2.return vo
        aws_result

    # end of parserImportKeyPairReturn


    #///////////////// Parser for DescribeKeyPairs return (need resolve) /////////////////
    #private (resolve result to vo )
    resolveDescribeKeyPairsResult = ( result ) ->
        #resolve result

        #return vo
        ($.xml2json ($.parseXML result[1])).DescribeKeyPairsResponse.keySet

    #private (parser DescribeKeyPairs return)
    parserDescribeKeyPairsReturn = ( result, return_code, param ) ->

        #1.resolve return_code
        aws_result = result_vo.processAWSReturnHandler result, return_code, param

        #2.resolve return_data when return_code is E_OK
        if return_code == constant.RETURN_CODE.E_OK && !aws_result.is_error

            resolved_data = resolveDescribeKeyPairsResult result

            aws_result.resolved_data = resolved_data


        #3.return vo
        aws_result

    # end of parserDescribeKeyPairsReturn


    #///////////////// Parser for upload return  /////////////////
    #private (parser upload return)
    parserUploadReturn = ( result, return_code, param ) ->

        #1.resolve return_code
        aws_result = result_vo.processAWSReturnHandler result, return_code, param

        #2.return vo
        aws_result

    # end of parserUploadReturn


    #///////////////// Parser for download return  /////////////////
    #private (parser download return)
    parserDownloadReturn = ( result, return_code, param ) ->

        #1.resolve return_code
        aws_result = result_vo.processAWSReturnHandler result, return_code, param

        #2.return vo
        aws_result

    # end of parserDownloadReturn


    #///////////////// Parser for remove return  /////////////////
    #private (parser remove return)
    parserRemoveReturn = ( result, return_code, param ) ->

        #1.resolve return_code
        aws_result = result_vo.processAWSReturnHandler result, return_code, param

        #2.return vo
        aws_result

    # end of parserRemoveReturn


    #///////////////// Parser for list return  /////////////////
    #private (parser list return)
    parserListReturn = ( result, return_code, param ) ->

        #1.resolve return_code
        aws_result = result_vo.processAWSReturnHandler result, return_code, param

        #2.return vo
        aws_result

    # end of parserListReturn


    #############################################################
    #public
    parserCreateKeyPairReturn                : parserCreateKeyPairReturn
    parserDeleteKeyPairReturn                : parserDeleteKeyPairReturn
    parserImportKeyPairReturn                : parserImportKeyPairReturn
    parserDescribeKeyPairsReturn             : parserDescribeKeyPairsReturn
    parserUploadReturn                       : parserUploadReturn
    parserDownloadReturn                     : parserDownloadReturn
    parserRemoveReturn                       : parserRemoveReturn
    parserListReturn                         : parserListReturn
    resolveDescribeKeyPairsResult            : resolveDescribeKeyPairsResult
