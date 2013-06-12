#*************************************************************************************
#* Filename     : log_service.coffee
#* Creator      : gen_service.sh
#* Create date  : 2013-06-04 15:13:07
#* Description  : service know back-end api
#* Action       : 1.invoke MC.api (send url, method, data)
#*                2.invoke parser
#*                3.invoke callback
# ************************************************************************************
# (c)Copyright 2012 Madeiracloud  All Rights Reserved
# ************************************************************************************

define [ 'MC', 'log_parser', 'result_vo' ], ( MC, log_parser, result_vo ) ->

    URL = '/log/'

    #private
    send_request =  ( api_name, src, param_ary, parser, callback ) ->

        #check callback
        if callback is null
            console.log "log." + api_name + " callback is null"
            return false

        try

            MC.api {
                url     : URL
                method  : api_name
                data    : param_ary
                success : ( result, return_code ) ->

                    #resolve result
                    param_ary.splice 0, 0, src
                    forge_result = {}
                    forge_result = parser result, return_code, param_ary

                    callback forge_result

                error : ( result, return_code ) ->

                    forge_result = {}
                    forge_result.return_code      = return_code
                    forge_result.is_error         = true
                    forge_result.error_message    = result.toString()

                    callback forge_result
            }

        catch error
            console.log "log." + api_name + " error:" + error.toString()


        true
    # end of send_request

    #def put_user_log(self, username, session_id, user_logs):
    put_user_log = ( src, username, session_id, user_logs, callback ) ->
        send_request "put_user_log", src, [ username, session_id, user_logs ], log_parser.parserPutUserLogReturn, callback
        true


    #############################################################
    #public
    put_user_log                 : put_user_log

