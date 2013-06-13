#*************************************************************************************
#* Filename     : stack_parser.coffee
#* Creator      : gen_service.sh
#* Create date  : 2013-05-25 14:06:02
#* Description  : parser return data of stack
# ************************************************************************************
# (c)Copyright 2012 Madeiracloud  All Rights Reserved
# ************************************************************************************

define [ 'stack_vo', 'result_vo', 'constant' ], ( stack_vo, result_vo, constant ) ->


    #///////////////// Parser for create return (need resolve) /////////////////
    #private (resolve result to vo )
    resolveCreateResult = ( result ) ->
        #resolve result
        #TO-DO

        #return vo
        result

    #private (parser create return)
    parserCreateReturn = ( result, return_code, param ) ->

        #1.resolve return_code
        forge_result = result_vo.processForgeReturnHandler result, return_code, param

        #2.resolve return_data when return_code is E_OK
        if return_code == constant.RETURN_CODE.E_OK && !forge_result.is_error

            resolved_data = resolveCreateResult result

            forge_result.resolved_data = resolved_data


        #3.return vo
        forge_result

    # end of parserCreateReturn


    #///////////////// Parser for remove return (need resolve) /////////////////
    #private (resolve result to vo )
    resolveRemoveResult = ( result ) ->
        #resolve result
        #TO-DO

        #return vo
        result

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


    #///////////////// Parser for save return (need resolve) /////////////////
    #private (resolve result to vo )
    resolveSaveResult = ( result ) ->
        #resolve result
        #TO-DO

        #return vo
        result

    #private (parser save return)
    parserSaveReturn = ( result, return_code, param ) ->

        #1.resolve return_code
        forge_result = result_vo.processForgeReturnHandler result, return_code, param

        #2.resolve return_data when return_code is E_OK
        if return_code == constant.RETURN_CODE.E_OK && !forge_result.is_error

            resolved_data = resolveSaveResult result

            forge_result.resolved_data = resolved_data


        #3.return vo
        forge_result

    # end of parserSaveReturn


    #///////////////// Parser for rename return (need resolve) /////////////////
    #private (resolve result to vo )
    resolveRenameResult = ( result ) ->
        #resolve result
        #TO-DO

        #return vo
        result

    #private (parser rename return)
    parserRenameReturn = ( result, return_code, param ) ->

        #1.resolve return_code
        forge_result = result_vo.processForgeReturnHandler result, return_code, param

        #2.resolve return_data when return_code is E_OK
        if return_code == constant.RETURN_CODE.E_OK && !forge_result.is_error

            resolved_data = resolveRenameResult result

            forge_result.resolved_data = resolved_data


        #3.return vo
        forge_result

    # end of parserRenameReturn


    #///////////////// Parser for run return (need resolve) /////////////////
    #private (resolve result to vo )
    resolveRunResult = ( result ) ->
        #resolve result
        stack_vo.stack_run.id              =   result[0]
        stack_vo.stack_run.state           =   result[1]
        stack_vo.stack_run.brief           =   result[2]
        stack_vo.stack_run.time_submit     =   result[3]
        stack_vo.stack_run.rid             =   result[4]

        #return vo
        stack_vo.stack_run

    #private (parser run return)
    parserRunReturn = ( result, return_code, param ) ->

        #1.resolve return_code
        forge_result = result_vo.processForgeReturnHandler result, return_code, param

        #2.resolve return_data when return_code is E_OK
        if return_code == constant.RETURN_CODE.E_OK && !forge_result.is_error

            resolved_data = resolveRunResult result

            forge_result.resolved_data = resolved_data


        #3.return vo
        forge_result

    # end of parserRunReturn


    #///////////////// Parser for save_as return (need resolve) /////////////////
    #private (resolve result to vo )
    resolveSaveAsResult = ( result ) ->
        #resolve result
        #TO-DO

        #return vo
        result

    #private (parser save_as return)
    parserSaveAsReturn = ( result, return_code, param ) ->

        #1.resolve return_code
        forge_result = result_vo.processForgeReturnHandler result, return_code, param

        #2.resolve return_data when return_code is E_OK
        if return_code == constant.RETURN_CODE.E_OK && !forge_result.is_error

            resolved_data = resolveSaveAsResult result

            forge_result.resolved_data = resolved_data


        #3.return vo
        forge_result

    # end of parserSaveAsReturn


    #///////////////// Parser for info return (need resolve) /////////////////
    #private (resolve result to vo )
    resolveInfoResult = ( result ) ->
        #resolve result

        #return vo
        result

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


    #///////////////// Parser for list return (need resolve) /////////////////
    #private (resolve result to vo )
    resolveListResult = ( result ) ->
        #resolve result
        stack_list = {}
        for vo in result
            if stack_list[vo.region] == undefined
                stack_list[vo.region]=[]

            stack_list[vo.region].push vo

        #return vo
        stack_vo.stack_list = stack_list
        stack_list

    #private (parser list return)
    parserListReturn = ( result, return_code, param ) ->

        #1.resolve return_code
        forge_result = result_vo.processForgeReturnHandler result, return_code, param

        #2.resolve return_data when return_code is E_OK
        if return_code == constant.RETURN_CODE.E_OK && !forge_result.is_error

            resolved_data = resolveListResult result

            forge_result.resolved_data = resolved_data


        #3.return vo
        forge_result

    # end of parserListReturn


    #############################################################
    #public
    parserCreateReturn                       : parserCreateReturn
    parserRemoveReturn                       : parserRemoveReturn
    parserSaveReturn                         : parserSaveReturn
    parserRenameReturn                       : parserRenameReturn
    parserRunReturn                          : parserRunReturn
    parserSaveAsReturn                       : parserSaveAsReturn
    parserInfoReturn                         : parserInfoReturn
    parserListReturn                         : parserListReturn

