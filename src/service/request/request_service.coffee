#*************************************************************************************
#* Filename     : request_service.coffee
#* Creator      : gen_service.sh
#* Create date  : 2013-05-25 14:05:58
#* Description  : service know back-end api
#* Action       : 1.invoke MC.api (send url, method, data)
#*                2.invoke parser
#*                3.invoke callback
# ************************************************************************************
# (c)Copyright 2012 Madeiracloud  All Rights Reserved
# ************************************************************************************

define [ 'MC', 'request_parser', 'result_vo' ], ( MC, request_parser, result_vo ) ->

    URL = '/request/'

    #private
    send_request =  ( api_name, param_ary, parser, callback ) ->

        #check callback
        if callback is null
            console.log "request." + api_name + " callback is null"
            return false

        try

            MC.api {
                url     : URL
                method  : api_name
                data    : param_ary
                success : ( result, return_code ) ->

                    #resolve result
                    result_vo.forge_result = parser result, return_code, param_ary

                    callback result_vo.forge_result

                error : ( result, return_code ) ->

                    result_vo.forge_result.return_code      = return_code
                    result_vo.forge_result.is_error         = true
                    result_vo.forge_result.error_message    = result.toString()

                    callback result_vo.forge_result
            }

        catch error
            console.log "request." + method + " error:" + error.toString()


        true
    # end of send_request

    #def init(self, username, session_id, region_name):
    init = ( username, session_id, region_name, callback ) ->
        send_request "init", [ username, session_id, region_name ], request_parser.parserInitReturn, callback
        true

    #def update(self, username, session_id, region_name, timestamp=None):
    update = ( username, session_id, region_name, timestamp=null, callback ) ->
        send_request "update", [ username, session_id, region_name, timestamp ], request_parser.parserUpdateReturn, callback
        true


    #############################################################
    #public
    init                         : init
    update                       : update

