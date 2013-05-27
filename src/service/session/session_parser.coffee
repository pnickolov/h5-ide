#*************************************************************************************
#* Filename     : session_parser.coffee
#* Creator      : gen_service.sh
#* Create date  : 2013-05-27 14:02:50
#* Description  : parser return data of session
# ************************************************************************************
# (c)Copyright 2012 Madeiracloud  All Rights Reserved
# ************************************************************************************

define [ 'session_vo', 'result_vo', 'constant' ], ( session_vo, result_vo, constant ) ->


    #///////////////// Parser for login return (need resolve) /////////////////
    #private (resolve result to vo )
    resolveLoginResult = ( result ) ->
        #resolve result
        session_vo.session_info.userid      = result[0]
        session_vo.session_info.usercode    = result[1]
        session_vo.session_info.session_id  = result[2]
        session_vo.session_info.region_name = result[3]
        session_vo.session_info.email       = result[4]
        session_vo.session_info.has_cred    = result[5]

        #return session_info
        session_vo.session_info

    #private (parser login return)
    parserLoginReturn = ( result, return_code, param ) ->

        #1.resolve return_code
        result_vo.forge_result = result_vo.processForgeReturnHandler result, return_code, param

        #2.resolve return_data when return_code is E_OK
        if return_code == constant.RETURN_CODE.E_OK && !result_vo.forge_result.is_error

            resolved_data = resolveLoginResult result

            result_vo.forge_result.resolved_data = resolved_data


        #3.return vo
        result_vo.forge_result

    # end of parserLoginReturn


    #///////////////// Parser for logout return (need resolve) /////////////////
    #private (resolve result to vo )
    resolveLogoutResult = ( result ) ->
        #resolve result
        #TO-DO

        #return vo
        #TO-DO

    #private (parser logout return)
    parserLogoutReturn = ( result, return_code, param ) ->

        #1.resolve return_code
        result_vo.forge_result = result_vo.processForgeReturnHandler result, return_code, param

        #2.resolve return_data when return_code is E_OK
        if return_code == constant.RETURN_CODE.E_OK && !result_vo.forge_result.is_error

            resolved_data = resolveLogoutResult result

            result_vo.forge_result.resolved_data = resolved_data


        #3.return vo
        result_vo.forge_result

    # end of parserLogoutReturn


    #///////////////// Parser for set_credential return (need resolve) /////////////////
    #private (resolve result to vo )
    resolveSetCredentialResult = ( result ) ->
        #resolve result
        #TO-DO

        #return vo
        #TO-DO

    #private (parser set_credential return)
    parserSetCredentialReturn = ( result, return_code, param ) ->

        #1.resolve return_code
        result_vo.forge_result = result_vo.processForgeReturnHandler result, return_code, param

        #2.resolve return_data when return_code is E_OK
        if return_code == constant.RETURN_CODE.E_OK && !result_vo.forge_result.is_error

            resolved_data = resolveSetCredentialResult result

            result_vo.forge_result.resolved_data = resolved_data


        #3.return vo
        result_vo.forge_result

    # end of parserSetCredentialReturn


    #///////////////// Parser for guest return (need resolve) /////////////////
    #private (resolve result to vo )
    resolveGuestResult = ( result ) ->
        #resolve result
        #TO-DO

        #return vo
        #TO-DO

    #private (parser guest return)
    parserGuestReturn = ( result, return_code, param ) ->

        #1.resolve return_code
        result_vo.forge_result = result_vo.processForgeReturnHandler result, return_code, param

        #2.resolve return_data when return_code is E_OK
        if return_code == constant.RETURN_CODE.E_OK && !result_vo.forge_result.is_error

            resolved_data = resolveGuestResult result

            result_vo.forge_result.resolved_data = resolved_data


        #3.return vo
        result_vo.forge_result

    # end of parserGuestReturn


    #############################################################
    #public
    parserLoginReturn                        : parserLoginReturn
    parserLogoutReturn                       : parserLogoutReturn
    parserSetCredentialReturn                : parserSetCredentialReturn
    parserGuestReturn                        : parserGuestReturn

