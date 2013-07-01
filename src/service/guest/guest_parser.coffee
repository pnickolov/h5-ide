#*************************************************************************************
#* Filename     : guest_parser.coffee
#* Creator      : gen_service.sh
#* Create date  : 2013-05-25 14:06:01
#* Description  : parser return data of guest
# ************************************************************************************
# (c)Copyright 2012 Madeiracloud  All Rights Reserved
# ************************************************************************************

define [  'result_vo', 'constant' ], (result_vo, constant ) ->


    #///////////////// Parser for invite return (need resolve) /////////////////
    #private (resolve result to vo )
    resolveInviteResult = ( result ) ->
        invite_info = {}

        #resolve result
        invite_info.request_id     = result[0]
        invite_info.state          = result[1]
        invite_info.request_brief  = result[2]
        invite_info.submit_time    = result[3]
        invite_info.request_rid    = result[4]

        #return vo
        invite_info

    #private (parser invite return)
    parserInviteReturn = ( result, return_code, param ) ->

        #1.resolve return_code
        forge_result = result_vo.processForgeReturnHandler result, return_code, param

        #2.resolve return_data when return_code is E_OK
        if return_code == constant.RETURN_CODE.E_OK && !forge_result.is_error

            resolved_data = resolveInviteResult result

            forge_result.resolved_data = resolved_data


        #3.return vo
        forge_result

    # end of parserInviteReturn


    #///////////////// Parser for cancel return (need resolve) /////////////////
    #private (resolve result to vo )
    resolveCancelResult = ( result ) ->
        #resolve result
        #TO-DO

        #return vo
        #TO-DO

    #private (parser cancel return)
    parserCancelReturn = ( result, return_code, param ) ->

        #1.resolve return_code
        forge_result = result_vo.processForgeReturnHandler result, return_code, param

        #2.resolve return_data when return_code is E_OK
        if return_code == constant.RETURN_CODE.E_OK && !forge_result.is_error

            resolved_data = resolveCancelResult result

            forge_result.resolved_data = resolved_data


        #3.return vo
        forge_result

    # end of parserCancelReturn


    #///////////////// Parser for access return (need resolve) /////////////////
    #private (resolve result to vo )
    resolveAccessResult = ( result ) ->
        #resolve result
        #TO-DO

        #return vo
        #TO-DO

    #private (parser access return)
    parserAccessReturn = ( result, return_code, param ) ->

        #1.resolve return_code
        forge_result = result_vo.processForgeReturnHandler result, return_code, param

        #2.resolve return_data when return_code is E_OK
        if return_code == constant.RETURN_CODE.E_OK && !forge_result.is_error

            resolved_data = resolveAccessResult result

            forge_result.resolved_data = resolved_data


        #3.return vo
        forge_result

    # end of parserAccessReturn


    #///////////////// Parser for end return (need resolve) /////////////////
    #private (resolve result to vo )
    resolveEndResult = ( result ) ->
        #resolve result
        #TO-DO

        #return vo
        #TO-DO

    #private (parser end return)
    parserEndReturn = ( result, return_code, param ) ->

        #1.resolve return_code
        forge_result = result_vo.processForgeReturnHandler result, return_code, param

        #2.resolve return_data when return_code is E_OK
        if return_code == constant.RETURN_CODE.E_OK && !forge_result.is_error

            resolved_data = resolveEndResult result

            forge_result.resolved_data = resolved_data


        #3.return vo
        forge_result

    # end of parserEndReturn


    #///////////////// Parser for info return (need resolve) /////////////////
    #private (resolve result to vo )
    resolveInfoResult = ( result ) ->
        #resolve result


        #return vo
        #TO-DO

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
    parserInviteReturn                       : parserInviteReturn
    parserCancelReturn                       : parserCancelReturn
    parserAccessReturn                       : parserAccessReturn
    parserEndReturn                          : parserEndReturn
    parserInfoReturn                         : parserInfoReturn

