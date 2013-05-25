#*************************************************************************************
#* Filename     : app_parser.coffee
#* Creator      : gen_service.sh
#* Create date  : 2013-05-25 14:05:59
#* Description  : parser return data of app
# ************************************************************************************
# (c)Copyright 2012 Madeiracloud  All Rights Reserved
# ************************************************************************************

define [ 'app_vo', 'result_vo', 'constant' ], ( app_vo, result_vo, constant ) ->


    #///////////////// Parser for create return (need resolve) /////////////////
    #private (resolve result to vo )
    resolveCreateResult = ( result ) ->
        #resolve result
        #TO-DO

        #return vo
        #TO-DO

    #private (parser create return)
    parserCreateReturn = ( result, return_code, param ) ->

        #1.resolve return_code
        result_vo.forge_result = result_vo.processForgeReturnHandler result, return_code, param

        #2.resolve return_data when return_code is E_OK
        if return_code == constant.RETURN_CODE.E_OK && !result_vo.forge_result.is_error

            resolved_data = resolveCreateResult result

            result_vo.forge_result.resolved_data = resolved_data


        #3.return vo
        result_vo.forge_result

    # end of parserCreateReturn


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


    #///////////////// Parser for rename return (need resolve) /////////////////
    #private (resolve result to vo )
    resolveRenameResult = ( result ) ->
        #resolve result
        #TO-DO

        #return vo
        #TO-DO

    #private (parser rename return)
    parserRenameReturn = ( result, return_code, param ) ->

        #1.resolve return_code
        result_vo.forge_result = result_vo.processForgeReturnHandler result, return_code, param

        #2.resolve return_data when return_code is E_OK
        if return_code == constant.RETURN_CODE.E_OK && !result_vo.forge_result.is_error

            resolved_data = resolveRenameResult result

            result_vo.forge_result.resolved_data = resolved_data


        #3.return vo
        result_vo.forge_result

    # end of parserRenameReturn


    #///////////////// Parser for terminate return (need resolve) /////////////////
    #private (resolve result to vo )
    resolveTerminateResult = ( result ) ->
        #resolve result
        #TO-DO

        #return vo
        #TO-DO

    #private (parser terminate return)
    parserTerminateReturn = ( result, return_code, param ) ->

        #1.resolve return_code
        result_vo.forge_result = result_vo.processForgeReturnHandler result, return_code, param

        #2.resolve return_data when return_code is E_OK
        if return_code == constant.RETURN_CODE.E_OK && !result_vo.forge_result.is_error

            resolved_data = resolveTerminateResult result

            result_vo.forge_result.resolved_data = resolved_data


        #3.return vo
        result_vo.forge_result

    # end of parserTerminateReturn


    #///////////////// Parser for start return (need resolve) /////////////////
    #private (resolve result to vo )
    resolveStartResult = ( result ) ->
        #resolve result
        #TO-DO

        #return vo
        #TO-DO

    #private (parser start return)
    parserStartReturn = ( result, return_code, param ) ->

        #1.resolve return_code
        result_vo.forge_result = result_vo.processForgeReturnHandler result, return_code, param

        #2.resolve return_data when return_code is E_OK
        if return_code == constant.RETURN_CODE.E_OK && !result_vo.forge_result.is_error

            resolved_data = resolveStartResult result

            result_vo.forge_result.resolved_data = resolved_data


        #3.return vo
        result_vo.forge_result

    # end of parserStartReturn


    #///////////////// Parser for stop return (need resolve) /////////////////
    #private (resolve result to vo )
    resolveStopResult = ( result ) ->
        #resolve result
        #TO-DO

        #return vo
        #TO-DO

    #private (parser stop return)
    parserStopReturn = ( result, return_code, param ) ->

        #1.resolve return_code
        result_vo.forge_result = result_vo.processForgeReturnHandler result, return_code, param

        #2.resolve return_data when return_code is E_OK
        if return_code == constant.RETURN_CODE.E_OK && !result_vo.forge_result.is_error

            resolved_data = resolveStopResult result

            result_vo.forge_result.resolved_data = resolved_data


        #3.return vo
        result_vo.forge_result

    # end of parserStopReturn


    #///////////////// Parser for reboot return (need resolve) /////////////////
    #private (resolve result to vo )
    resolveRebootResult = ( result ) ->
        #resolve result
        #TO-DO

        #return vo
        #TO-DO

    #private (parser reboot return)
    parserRebootReturn = ( result, return_code, param ) ->

        #1.resolve return_code
        result_vo.forge_result = result_vo.processForgeReturnHandler result, return_code, param

        #2.resolve return_data when return_code is E_OK
        if return_code == constant.RETURN_CODE.E_OK && !result_vo.forge_result.is_error

            resolved_data = resolveRebootResult result

            result_vo.forge_result.resolved_data = resolved_data


        #3.return vo
        result_vo.forge_result

    # end of parserRebootReturn


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


    #///////////////// Parser for resource return (need resolve) /////////////////
    #private (resolve result to vo )
    resolveResourceResult = ( result ) ->
        #resolve result
        #TO-DO

        #return vo
        #TO-DO

    #private (parser resource return)
    parserResourceReturn = ( result, return_code, param ) ->

        #1.resolve return_code
        result_vo.forge_result = result_vo.processForgeReturnHandler result, return_code, param

        #2.resolve return_data when return_code is E_OK
        if return_code == constant.RETURN_CODE.E_OK && !result_vo.forge_result.is_error

            resolved_data = resolveResourceResult result

            result_vo.forge_result.resolved_data = resolved_data


        #3.return vo
        result_vo.forge_result

    # end of parserResourceReturn


    #///////////////// Parser for summary return (need resolve) /////////////////
    #private (resolve result to vo )
    resolveSummaryResult = ( result ) ->
        #resolve result
        #TO-DO

        #return vo
        #TO-DO

    #private (parser summary return)
    parserSummaryReturn = ( result, return_code, param ) ->

        #1.resolve return_code
        result_vo.forge_result = result_vo.processForgeReturnHandler result, return_code, param

        #2.resolve return_data when return_code is E_OK
        if return_code == constant.RETURN_CODE.E_OK && !result_vo.forge_result.is_error

            resolved_data = resolveSummaryResult result

            result_vo.forge_result.resolved_data = resolved_data


        #3.return vo
        result_vo.forge_result

    # end of parserSummaryReturn


    #############################################################
    #public
    parserCreateReturn                       : parserCreateReturn
    parserUpdateReturn                       : parserUpdateReturn
    parserRenameReturn                       : parserRenameReturn
    parserTerminateReturn                    : parserTerminateReturn
    parserStartReturn                        : parserStartReturn
    parserStopReturn                         : parserStopReturn
    parserRebootReturn                       : parserRebootReturn
    parserInfoReturn                         : parserInfoReturn
    parserResourceReturn                     : parserResourceReturn
    parserSummaryReturn                      : parserSummaryReturn

