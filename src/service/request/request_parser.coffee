#*************************************************************************************
#* Filename     : request_parser.coffee
#* Creator      : gen_service.sh
#* Create date  : 2013-05-25 14:05:58
#* Description  : parser return data of request
# ************************************************************************************
# (c)Copyright 2012 Madeiracloud  All Rights Reserved
# ************************************************************************************

define [ 'request_vo', 'result_vo', 'constant' ], ( request_vo, result_vo, constant ) ->


    #///////////////// Parser for init return (need resolve) /////////////////
    #private (resolve result to vo )
    resolveInitResult = ( result ) ->
        #resolve result
        #TO-DO

        #return vo
        #TO-DO

    #private (parser init return)
    parserInitReturn = ( result, return_code, param ) ->

        #1.resolve return_code
        result_vo.forge_result = result_vo.processForgeReturnHandler result, return_code, param

        #2.resolve return_data when return_code is E_OK
        if return_code == constant.RETURN_CODE.E_OK && !result_vo.forge_result.is_error

            resolved_data = resolveInitResult result

            result_vo.forge_result.resolved_data = resolved_data


        #3.return vo
        result_vo.forge_result

    # end of parserInitReturn


    #///////////////// Parser for update return (need resolve) /////////////////
    #private (resolve result to vo )
    resolveUpdateResult = ( result ) ->
        #resolve result
        #TO-DO

        #return vo
        #TO-DO

    #private (parser update return)
    parserUpdateReturn = ( result, return_code, param ) ->

        #1.resolve return_code
        result_vo.forge_result = result_vo.processForgeReturnHandler result, return_code, param

        #2.resolve return_data when return_code is E_OK
        if return_code == constant.RETURN_CODE.E_OK && !result_vo.forge_result.is_error

            resolved_data = resolveUpdateResult result

            result_vo.forge_result.resolved_data = resolved_data


        #3.return vo
        result_vo.forge_result

    # end of parserUpdateReturn


    #############################################################
    #public
    parserInitReturn                         : parserInitReturn
    parserUpdateReturn                       : parserUpdateReturn

