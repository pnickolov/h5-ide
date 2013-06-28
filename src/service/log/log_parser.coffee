#*************************************************************************************
#* Filename     : log_parser.coffee
#* Creator      : gen_service.sh
#* Create date  : 2013-05-25 14:05:57
#* Description  : parser return data of log
# ************************************************************************************
# (c)Copyright 2012 Madeiracloud  All Rights Reserved
# ************************************************************************************

define [  'result_vo', 'constant' ], (result_vo, constant ) ->


    #///////////////// Parser for put_user_log return (need resolve) /////////////////
    #private (resolve result to vo )
    resolvePutUserLogResult = ( result ) ->
        #resolve result
        #TO-DO

        #return vo
        #TO-DO

    #private (parser put_user_log return)
    parserPutUserLogReturn = ( result, return_code, param ) ->

        #1.resolve return_code
        forge_result = result_vo.processForgeReturnHandler result, return_code, param

        #2.resolve return_data when return_code is E_OK
        if return_code == constant.RETURN_CODE.E_OK && !forge_result.is_error

            resolved_data = resolvePutUserLogResult result

            forge_result.resolved_data = resolved_data


        #3.return vo
        forge_result

    # end of parserPutUserLogReturn


    #############################################################
    #public
    parserPutUserLogReturn                   : parserPutUserLogReturn

