#*************************************************************************************
#* Filename     : state_service.coffee
#* Creator      : gen_service.sh
#* Create date  : 2013-12-11 11:20:00
#* Description  : service know back-end api
#* Action       : 1.invoke MC.api (send url, method, data)
#*                2.invoke parser
#*                3.invoke callback
# ************************************************************************************
# (c)Copyright 2012 Madeiracloud  All Rights Reserved
# ************************************************************************************

define [ 'MC', 'constant', 'result_vo' ], ( MC, constant, result_vo ) ->

    URL = '/state/'

    #private
    send_request =  ( api_name, src, param_ary, parser, callback ) ->

        #check callback
        if callback is null
            console.log "state." + api_name + " callback is null"
            return false

        try

            MC.api {
                url     : URL
                method  : api_name
                data    : param_ary
                success : ( result, return_code ) ->

                    #resolve result
                    param_ary.splice 0, 0, { url:URL, method:api_name, src:src }
                    forge_result = {}
                    forge_result = parser result, return_code, param_ary

                    callback forge_result

                error : ( result, return_code ) ->

                    forge_result = {}
                    forge_result.return_code      = return_code
                    forge_result.is_error         = true
                    forge_result.error_message    = result.toString()

                    param_ary.splice 0, 0, { url:URL, method:api_name, src:src }
                    forge_result.param = param_ary

                    callback forge_result
            }

        catch error
            console.log "state." + method + " error:" + error.toString()


        true
    # end of send_request

    #///////////////// Parser for module return (need resolve) /////////////////
    #private (resolve result to vo )
    resolveModuleResult = ( result ) ->
        #resolve result
        #TO-DO

        #return vo
        #TO-DO

    #private (parser module return)
    parserModuleReturn = ( result, return_code, param ) ->

        #1.resolve return_code
        forge_result = result_vo.processForgeReturnHandler result, return_code, param

        #2.resolve return_data when return_code is E_OK
        if return_code == constant.RETURN_CODE.E_OK && !forge_result.is_error

            resolved_data = resolveModuleResult result

            forge_result.resolved_data = resolved_data


        #3.return vo
        forge_result

    # end of parserModuleReturn

    #def module(self, username, session_id):
    module = ( src, username, session_id, callback ) ->
        send_request "module", src, [ username, session_id ], parserModuleReturn, callback
        true


    #############################################################
    #public
    module                       : module

