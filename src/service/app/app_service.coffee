#*************************************************************************************
#* Filename     : app_service.coffee
#* Creator      : gen_service.sh
#* Create date  : 2013-06-04 15:13:08
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
    send_request =  ( api_name, src, param_ary, parser, callback ) ->

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
                    param_ary.splice 0, 0, src
                    result_vo.forge_result = parser result, return_code, param_ary

                    callback result_vo.forge_result

                error : ( result, return_code ) ->

                    result_vo.forge_result.return_code      = return_code
                    result_vo.forge_result.is_error         = true
                    result_vo.forge_result.error_message    = result.toString()

                    callback result_vo.forge_result
            }

        catch error
            console.log "app." + api_name + " error:" + error.toString()


        true
    # end of send_request

    #def create(self, username, session_id, region_name, spec):
    create = ( src, username, session_id, region_name, spec, callback ) ->
        send_request "create", src, [ username, session_id, region_name, spec ], app_parser.parserCreateReturn, callback
        true

    #def update(self, username, session_id, region_name, spec, app_id):
    update = ( src, username, session_id, region_name, spec, app_id, callback ) ->
        send_request "update", src, [ username, session_id, region_name, spec, app_id ], app_parser.parserUpdateReturn, callback
        true

    #def rename(self, username, session_id, region_name, app_id, new_name, app_name=None):
    rename = ( src, username, session_id, region_name, app_id, new_name, app_name=null, callback ) ->
        send_request "rename", src, [ username, session_id, region_name, app_id, new_name, app_name ], app_parser.parserRenameReturn, callback
        true

    #def terminate(self, username, session_id, region_name, app_id, app_name=None):
    terminate = ( src, username, session_id, region_name, app_id, app_name=null, callback ) ->
        send_request "terminate", src, [ username, session_id, region_name, app_id, app_name ], app_parser.parserTerminateReturn, callback
        true

    #def start(self, username, session_id, region_name, app_id, app_name=None):
    start = ( src, username, session_id, region_name, app_id, app_name=null, callback ) ->
        send_request "start", src, [ username, session_id, region_name, app_id, app_name ], app_parser.parserStartReturn, callback
        true

    #def stop(self, username, session_id, region_name, app_id, app_name=None):
    stop = ( src, username, session_id, region_name, app_id, app_name=null, callback ) ->
        send_request "stop", src, [ username, session_id, region_name, app_id, app_name ], app_parser.parserStopReturn, callback
        true

    #def reboot(self, username, session_id, region_name, app_id, app_name=None):
    reboot = ( src, username, session_id, region_name, app_id, app_name=null, callback ) ->
        send_request "reboot", src, [ username, session_id, region_name, app_id, app_name ], app_parser.parserRebootReturn, callback
        true

    #def info(self, username, session_id, region_name, app_ids=None):
    info = ( src, username, session_id, region_name, app_ids=null, callback ) ->
        send_request "info", src, [ username, session_id, region_name, app_ids ], app_parser.parserInfoReturn, callback
        true

    #def list(self, username, session_id, region_name, app_ids=None):
    list = ( src, username, session_id, region_name, app_ids=null, callback ) ->
        send_request "list", src, [ username, session_id, region_name, app_ids ], app_parser.parserListReturn, callback
        true

    #def resource(self, username, session_id, region_name, app_id):
    resource = ( src, username, session_id, region_name, app_id, callback ) ->
        send_request "resource", src, [ username, session_id, region_name, app_id ], app_parser.parserResourceReturn, callback
        true

    #def summary(self, username, session_id, region_name=None):
    summary = ( src, username, session_id, region_name=null, callback ) ->
        send_request "summary", src, [ username, session_id, region_name ], app_parser.parserSummaryReturn, callback
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
    list                         : list
    resource                     : resource
    summary                      : summary

