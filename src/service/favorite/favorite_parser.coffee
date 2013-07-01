#*************************************************************************************
#* Filename     : favorite_parser.coffee
#* Creator      : gen_service.sh
#* Create date  : 2013-05-25 14:06:01
#* Description  : parser return data of favorite
# ************************************************************************************
# (c)Copyright 2012 Madeiracloud  All Rights Reserved
# ************************************************************************************

define [  'result_vo', 'constant' ], (result_vo, constant ) ->


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
        forge_result = result_vo.processForgeReturnHandler result, return_code, param

        #2.resolve return_data when return_code is E_OK
        if return_code == constant.RETURN_CODE.E_OK && !forge_result.is_error

            resolved_data = resolveAddResult result

            forge_result.resolved_data = resolved_data


        #3.return vo
        forge_result

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
        forge_result = result_vo.processForgeReturnHandler result, return_code, param

        #2.resolve return_data when return_code is E_OK
        if return_code == constant.RETURN_CODE.E_OK && !forge_result.is_error

            resolved_data = resolveRemoveResult result

            forge_result.resolved_data = resolved_data


        #3.return vo
        forge_result

    # end of parserRemoveReturn


    #///////////////// Parser for info return (need resolve) /////////////////
    #private (resolve result to vo )
    resolveInfoResult = ( result ) ->
        favorite_list = []
        #resolve result

        for res in result
            resource_info = {}
            resource_info.usercode      = res['username']
            resource_info.region        = res['region']
            resource_info.provider      = res['provider']
            resource_info.service       = res['service']
            resource_info.resource_type = res['resource']
            resource_info.resource_id   = res['id']
            resource_info.resource_info = res['amiVO']

            favorite_list.push resource_info

        #return vo
        favorite_list

    #private (parser info return)
    parserInfoReturn = ( result, return_code, param ) ->

        #1.resolve return_code
        forge_result = result_vo.processForgeReturnHandler result, return_code, param

        #2.resolve return_data when return_code is E_OK
        if return_code == constant.RETURN_CODE.E_OK && !forge_result.is_error

            resolved_data = resolveInfoResult result

            forge_result.resolved_data = resolved_data


        #3.return vo
        forge_result

    # end of parserInfoReturn


    #############################################################
    #public
    parserAddReturn                          : parserAddReturn
    parserRemoveReturn                       : parserRemoveReturn
    parserInfoReturn                         : parserInfoReturn

