#*************************************************************************************
#* Filename     : guest_service.coffee
#* Creator      : gen_service.sh
#* Create date  : 2013-06-04 15:13:09
#* Description  : service know back-end api
#* Action       : 1.invoke MC.api (send url, method, data)
#*                2.invoke parser
#*                3.invoke callback
# ************************************************************************************
# (c)Copyright 2012 Madeiracloud  All Rights Reserved
# ************************************************************************************

define [ 'MC', 'guest_parser', 'result_vo' ], ( MC, guest_parser, result_vo ) ->

    URL = '/guest/'

    #private
    send_request =  ( api_name, src, param_ary, parser, callback ) ->

        #check callback
        if callback is null
            console.log "guest." + api_name + " callback is null"
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
            console.log "guest." + method + " error:" + error.toString()


        true
    # end of send_request

    #def invite(self, username, session_id, region_name, guest_emails, stack_id,
    invite = ( src, username, session_id, region_name, callback ) ->
        send_request "invite", src, [ username, session_id, region_name ], guest_parser.parserInviteReturn, callback
        true

    #def cancel(self, username, session_id, region_name, guest_id):
    cancel = ( src, username, session_id, region_name, guest_id, callback ) ->
        send_request "cancel", src, [ username, session_id, region_name, guest_id ], guest_parser.parserCancelReturn, callback
        true

    #def access(self, guestname, session_id, region_name, guest_id):
    access = ( src, guestname, session_id, region_name, guest_id, callback ) ->
        send_request "access", src, [ guestname, session_id, region_name, guest_id ], guest_parser.parserAccessReturn, callback
        true

    #def end(self, guestname, session_id, region_name, guest_id):
    end = ( src, guestname, session_id, region_name, guest_id, callback ) ->
        send_request "end", src, [ guestname, session_id, region_name, guest_id ], guest_parser.parserEndReturn, callback
        true

    #def info(self, username, session_id, region_name, guest_id=None):
    info = ( src, username, session_id, region_name, guest_id=null, callback ) ->
        send_request "info", src, [ username, session_id, region_name, guest_id ], guest_parser.parserInfoReturn, callback
        true


    #############################################################
    #public
    invite                       : invite
    cancel                       : cancel
    access                       : access
    end                          : end
    info                         : info

