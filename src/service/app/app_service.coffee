#*************************************************************************************
#* Filename     : app_service.coffee
#* Creator      : gen_service.sh
#* Create date  : 2013-05-25 14:05:59
#* Description  : service know back-end api
#* Action       : 1.invoke MC.api (send url, method, data)
#*                2.invoke parser
#*                3.invoke callback
# ************************************************************************************
# (c)Copyright 2012 Madeiracloud  All Rights Reserved
# ************************************************************************************

define [ 'MC', 'app_parser', 'result_vo' ], ( MC, app_parser, result_vo ) ->

    URL = '/app/'

    #private
    send_request =  ( api_name, param_ary, parser, callback ) ->

        #check callback
        if callback is null
            console.log "app." + api_name + " callback is null"
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
            console.log "app." + method + " error:" + error.toString()


        true
    # end of send_request

    #def create(self, username, session_id, region_name, spec):
    create = ( username, session_id, region_name, spec, callback ) ->
        send_request "create", [ username, session_id, region_name, spec ], app_parser.parserCreateReturn, callback
        true

    #def update(self, username, session_id, region_name, spec, app_id):
    update = ( username, session_id, region_name, spec, app_id, callback ) ->
        send_request "update", [ username, session_id, region_name, spec, app_id ], app_parser.parserUpdateReturn, callback
        true

    #def rename(self, username, session_id, region_name, app_id, new_name, app_name=None):
    rename = ( username, session_id, region_name, app_id, new_name, app_name=null, callback ) ->
        send_request "rename", [ username, session_id, region_name, app_id, new_name, app_name ], app_parser.parserRenameReturn, callback
        true

    #def terminate(self, username, session_id, region_name, app_id, app_name=None):
    terminate = ( username, session_id, region_name, app_id, app_name=null, callback ) ->
        send_request "terminate", [ username, session_id, region_name, app_id, app_name ], app_parser.parserTerminateReturn, callback
        true

    #def start(self, username, session_id, region_name, app_id, app_name=None):
    start = ( username, session_id, region_name, app_id, app_name=null, callback ) ->
        send_request "start", [ username, session_id, region_name, app_id, app_name ], app_parser.parserStartReturn, callback
        true

    #def stop(self, username, session_id, region_name, app_id, app_name=None):
    stop = ( username, session_id, region_name, app_id, app_name=null, callback ) ->
        send_request "stop", [ username, session_id, region_name, app_id, app_name ], app_parser.parserStopReturn, callback
        true

    #def reboot(self, username, session_id, region_name, app_id, app_name=None):
    reboot = ( username, session_id, region_name, app_id, app_name=null, callback ) ->
        send_request "reboot", [ username, session_id, region_name, app_id, app_name ], app_parser.parserRebootReturn, callback
        true

    #def info(self, username, session_id, region_name, app_ids=None):
    info = ( username, session_id, region_name, app_ids=null, callback ) ->
        send_request "info", [ username, session_id, region_name, app_ids ], app_parser.parserInfoReturn, callback
        true

    #def resource(self, username, session_id, region_name, app_id):
    resource = ( username, session_id, region_name, app_id, callback ) ->
        send_request "resource", [ username, session_id, region_name, app_id ], app_parser.parserResourceReturn, callback
        true

    #def summary(self, username, session_id, region_name=None):
    summary = ( username, session_id, region_name=null, callback ) ->
        send_request "summary", [ username, session_id, region_name ], app_parser.parserSummaryReturn, callback
        true


    #############################################################
    #public
    create                       : create
    update                       : update
    rename                       : rename
    terminate                    : terminate
    start                        : start
    stop                         : stop
    reboot                       : reboot
    info                         : info
    resource                     : resource
    summary                      : summary

