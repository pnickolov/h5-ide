#*************************************************************************************
#* Filename     : iam_parser.coffee
#* Creator      : gen_service.sh
#* Create date  : 2013-05-25 14:06:16
#* Description  : parser return data of iam
# ************************************************************************************
# (c)Copyright 2012 Madeiracloud  All Rights Reserved
# ************************************************************************************

define [ 'iam_vo', 'result_vo', 'constant' ], ( iam_vo, result_vo, constant ) ->


    #///////////////// Parser for GetServerCertificate return (need resolve) /////////////////
    #private (resolve result to vo )
    resolveGetServerCertificateResult = ( result ) ->
        #resolve result

        #return vo
        ($.xml2json ($.parseXML result[1])).GetServerCertificateResponse.GetServerCertificateResult

    #private (parser GetServerCertificate return)
    parserGetServerCertificateReturn = ( result, return_code, param ) ->

        #1.resolve return_code
        result_vo.aws_result = result_vo.processAWSReturnHandler result, return_code, param

        #2.resolve return_data when return_code is E_OK
        if return_code == constant.RETURN_CODE.E_OK && !result_vo.aws_result.is_error

            resolved_data = resolveGetServerCertificateResult result

            result_vo.aws_result.resolved_data = resolved_data


        #3.return vo
        result_vo.aws_result

    # end of parserGetServerCertificateReturn


    #///////////////// Parser for ListServerCertificates return (need resolve) /////////////////
    #private (resolve result to vo )
    resolveListServerCertificatesResult = ( result ) ->
        #resolve result

        #return vo
        ($.xml2json ($.parseXML result[1])).ListServerCertificatesResponse.ListServerCertificatesResult

    #private (parser ListServerCertificates return)
    parserListServerCertificatesReturn = ( result, return_code, param ) ->

        #1.resolve return_code
        result_vo.aws_result = result_vo.processAWSReturnHandler result, return_code, param

        #2.resolve return_data when return_code is E_OK
        if return_code == constant.RETURN_CODE.E_OK && !result_vo.aws_result.is_error

            resolved_data = resolveListServerCertificatesResult result

            result_vo.aws_result.resolved_data = resolved_data


        #3.return vo
        result_vo.aws_result

    # end of parserListServerCertificatesReturn


    #############################################################
    #public
    parserGetServerCertificateReturn         : parserGetServerCertificateReturn
    parserListServerCertificatesReturn       : parserListServerCertificatesReturn
    resolveGetServerCertificateResult        : resolveGetServerCertificateResult
