#*************************************************************************************
#* Filename     : favorite_parser.coffee
#* Creator      : gen_service.sh
#* Create date  : 2013-05-25 14:06:01
#* Description  : parser return data of favorite
# ************************************************************************************
# (c)Copyright 2012 Madeiracloud  All Rights Reserved
# ************************************************************************************

define [ 'favorite_vo', 'result_vo', 'constant' ], ( favorite_vo, result_vo, constant ) ->


    #///////////////// Parser for add return (need resolve) /////////////////
    #private (resolve result to vo )
    resolveAddResult = ( result ) ->
        #resolve result
        #TO-DO

        #return vo
        #TO-DO

    #private (parser add return)
    parserAddReturn = ( result, return_code, param ) ->

        #1.resolve return_code
        result_vo.forge_result = result_vo.processForgeReturnHandler result, return_code, param

        #2.resolve return_data when return_code is E_OK
        if return_code == constant.RETURN_CODE.E_OK && !result_vo.forge_result.is_error

            resolved_data = resolveAddResult result

            result_vo.forge_result.resolved_data = resolved_data


        #3.return vo
        result_vo.forge_result

    # end of parserAddReturn


    #///////////////// Parser for remove return (need resolve) /////////////////
    #private (resolve result to vo )
    resolveRemoveResult = ( result ) ->
        #resolve result
        #TO-DO

        #return vo
        #TO-DO

    #private (parser remove return)
    parserRemoveReturn = ( result, return_code, param ) ->

        #1.resolve return_code
        result_vo.forge_result = result_vo.processForgeReturnHandler result, return_code, param

        #2.resolve return_data when return_code is E_OK
        if return_code == constant.RETURN_CODE.E_OK && !result_vo.forge_result.is_error

            resolved_data = resolveRemoveResult result

            result_vo.forge_result.resolved_data = resolved_data


        #3.return vo
        result_vo.forge_result

    # end of parserRemoveReturn


    #///////////////// Parser for info return (need resolve) /////////////////
    #private (resolve result to vo )
    resolveInfoResult = ( result ) ->
        #resolve result
        #TO-DO

        #return vo
        #TO-DO

    #private (parser info return)
    parserInfoReturn = ( result, return_code, param ) ->

        #1.resolve return_code
        result_vo.forge_result = result_vo.processForgeReturnHandler result, return_code, param

        #2.resolve return_data when return_code is E_OK
        if return_code == constant.RETURN_CODE.E_OK && !result_vo.forge_result.is_error

            resolved_data = resolveInfoResult result

            result_vo.forge_result.resolved_data = resolved_data


        #3.return vo
        result_vo.forge_result

    # end of parserInfoReturn


    #############################################################
    #public
    parserAddReturn                          : parserAddReturn
    parserRemoveReturn                       : parserRemoveReturn
    parserInfoReturn                         : parserInfoReturn

