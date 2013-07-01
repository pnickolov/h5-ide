#*************************************************************************************
#* Filename     : public_parser.coffee
#* Creator      : gen_service.sh
#* Create date  : 2013-05-25 14:05:58
#* Description  : parser return data of public
# ************************************************************************************
# (c)Copyright 2012 Madeiracloud  All Rights Reserved
# ************************************************************************************

define [  'result_vo', 'constant' ], (result_vo, constant ) ->


    #///////////////// Parser for get_hostname return (need resolve) /////////////////
    #private (resolve result to vo )
    resolveGetHostnameResult = ( result ) ->
        #resolve result
        #TO-DO

        #return vo
        #TO-DO

    #private (parser get_hostname return)
    parserGetHostnameReturn = ( result, return_code, param ) ->

        #1.resolve return_code
        forge_result = result_vo.processForgeReturnHandler result, return_code, param

        #2.resolve return_data when return_code is E_OK
        if return_code == constant.RETURN_CODE.E_OK && !forge_result.is_error

            resolved_data = resolveGetHostnameResult result

            forge_result.resolved_data = resolved_data


        #3.return vo
        forge_result

    # end of parserGetHostnameReturn


    #///////////////// Parser for get_dns_ip return (need resolve) /////////////////
    #private (resolve result to vo )
    resolveGetDnsIpResult = ( result ) ->
        #resolve result
        #TO-DO

        #return vo
        #TO-DO

    #private (parser get_dns_ip return)
    parserGetDnsIpReturn = ( result, return_code, param ) ->

        #1.resolve return_code
        forge_result = result_vo.processForgeReturnHandler result, return_code, param

        #2.resolve return_data when return_code is E_OK
        if return_code == constant.RETURN_CODE.E_OK && !forge_result.is_error

            resolved_data = resolveGetDnsIpResult result

            forge_result.resolved_data = resolved_data


        #3.return vo
        forge_result

    # end of parserGetDnsIpReturn


    #############################################################
    #public
    parserGetHostnameReturn                  : parserGetHostnameReturn
    parserGetDnsIpReturn                     : parserGetDnsIpReturn

