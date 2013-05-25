#*************************************************************************************
#* Filename     : sdb_parser.coffee
#* Creator      : gen_service.sh
#* Create date  : 2013-05-25 14:06:21
#* Description  : parser return data of sdb
# ************************************************************************************
# (c)Copyright 2012 Madeiracloud  All Rights Reserved
# ************************************************************************************

define [ 'sdb_vo', 'result_vo', 'constant' ], ( sdb_vo, result_vo, constant ) ->


    #///////////////// Parser for DomainMetadata return  /////////////////
    #private (parser DomainMetadata return)
    parserDomainMetadataReturn = ( result, return_code, param ) ->

        #1.resolve return_code
        result_vo.aws_result = result_vo.processAWSReturnHandler result, return_code, param

        #2.return vo
        result_vo.aws_result

    # end of parserDomainMetadataReturn


    #///////////////// Parser for GetAttributes return (need resolve) /////////////////
    #private (resolve result to vo )
    resolveGetAttributesResult = ( result ) ->
        #resolve result
        #TO-DO

        #return vo
        #TO-DO

    #private (parser GetAttributes return)
    parserGetAttributesReturn = ( result, return_code, param ) ->

        #1.resolve return_code
        result_vo.aws_result = result_vo.processAWSReturnHandler result, return_code, param

        #2.resolve return_data when return_code is E_OK
        if return_code == constant.RETURN_CODE.E_OK && !result_vo.aws_result.is_error

            resolved_data = resolveGetAttributesResult result

            result_vo.aws_result.resolved_data = resolved_data


        #3.return vo
        result_vo.aws_result

    # end of parserGetAttributesReturn


    #///////////////// Parser for ListDomains return (need resolve) /////////////////
    #private (resolve result to vo )
    resolveListDomainsResult = ( result ) ->
        #resolve result
        #TO-DO

        #return vo
        #TO-DO

    #private (parser ListDomains return)
    parserListDomainsReturn = ( result, return_code, param ) ->

        #1.resolve return_code
        result_vo.aws_result = result_vo.processAWSReturnHandler result, return_code, param

        #2.resolve return_data when return_code is E_OK
        if return_code == constant.RETURN_CODE.E_OK && !result_vo.aws_result.is_error

            resolved_data = resolveListDomainsResult result

            result_vo.aws_result.resolved_data = resolved_data


        #3.return vo
        result_vo.aws_result

    # end of parserListDomainsReturn


    #############################################################
    #public
    parserDomainMetadataReturn               : parserDomainMetadataReturn
    parserGetAttributesReturn                : parserGetAttributesReturn
    parserListDomainsReturn                  : parserListDomainsReturn

