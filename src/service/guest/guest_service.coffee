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

define [ 'MC', 'constant', 'result_vo' ], ( MC, constant, result_vo ) ->

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
                    param_ary.splice 0, 0, { url:URL, method:api_name, src:src }
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
            console.log "guest." + api_name + " error:" + error.toString()


        true
    # end of send_request

    #///////////////// Parser for invite return (need resolve) /////////////////
    #private (resolve result to vo )
    resolveInviteResult = ( result ) ->
        invite_info = {}

        #resolve result
        invite_info.request_id     = result[0]
        invite_info.state          = result[1]
        invite_info.request_brief  = result[2]
        invite_info.submit_time    = result[3]
        invite_info.request_rid    = result[4]

        #return vo
        invite_info

    #private (parser invite return)
    parserInviteReturn = ( result, return_code, param ) ->

        #1.resolve return_code
        forge_result = result_vo.processForgeReturnHandler result, return_code, param

        #2.resolve return_data when return_code is E_OK
        if return_code == constant.RETURN_CODE.E_OK && !forge_result.is_error

            resolved_data = resolveInviteResult result

            forge_result.resolved_data = resolved_data


        #3.return vo
        forge_result

    # end of parserInviteReturn


    #///////////////// Parser for cancel return (need resolve) /////////////////
    #private (resolve result to vo )
    resolveCancelResult = ( result ) ->
        #resolve result
        #TO-DO

        #return vo
        #TO-DO

    #private (parser cancel return)
    parserCancelReturn = ( result, return_code, param ) ->

        #1.resolve return_code
        forge_result = result_vo.processForgeReturnHandler result, return_code, param

        #2.resolve return_data when return_code is E_OK
        if return_code == constant.RETURN_CODE.E_OK && !forge_result.is_error

            resolved_data = resolveCancelResult result

            forge_result.resolved_data = resolved_data


        #3.return vo
        forge_result

    # end of parserCancelReturn


    #///////////////// Parser for access return (need resolve) /////////////////
    #private (resolve result to vo )
    resolveAccessResult = ( result ) ->
        #resolve result
        #TO-DO

        #return vo
        #TO-DO

    #private (parser access return)
    parserAccessReturn = ( result, return_code, param ) ->

        #1.resolve return_code
        forge_result = result_vo.processForgeReturnHandler result, return_code, param

        #2.resolve return_data when return_code is E_OK
        if return_code == constant.RETURN_CODE.E_OK && !forge_result.is_error

            resolved_data = resolveAccessResult result

            forge_result.resolved_data = resolved_data


        #3.return vo
        forge_result

    # end of parserAccessReturn


    #///////////////// Parser for end return (need resolve) /////////////////
    #private (resolve result to vo )
    resolveEndResult = ( result ) ->
        #resolve result
        #TO-DO

        #return vo
        #TO-DO

    #private (parser end return)
    parserEndReturn = ( result, return_code, param ) ->

        #1.resolve return_code
        forge_result = result_vo.processForgeReturnHandler result, return_code, param

        #2.resolve return_data when return_code is E_OK
        if return_code == constant.RETURN_CODE.E_OK && !forge_result.is_error

            resolved_data = resolveEndResult result

            forge_result.resolved_data = resolved_data


        #3.return vo
        forge_result

    # end of parserEndReturn


    #///////////////// Parser for info return (need resolve) /////////////////
    #private (resolve result to vo )
    resolveInfoResult = ( result ) ->
        #resolve result


        #return vo
        #TO-DO

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


    #############################################################

    #def invite(self, username, session_id, region_name, guest_emails, stack_id,
    invite = ( src, username, session_id, region_name, callback ) ->
        send_request "invite", src, [ username, session_id, region_name ], parserInviteReturn, callback
        true

    #def cancel(self, username, session_id, region_name, guest_id):
    cancel = ( src, username, session_id, region_name, guest_id, callback ) ->
        send_request "cancel", src, [ username, session_id, region_name, guest_id ], parserCancelReturn, callback
        true

    #def access(self, guestname, session_id, region_name, guest_id):
    access = ( src, guestname, session_id, region_name, guest_id, callback ) ->
        send_request "access", src, [ guestname, session_id, region_name, guest_id ], parserAccessReturn, callback
        true

    #def end(self, guestname, session_id, region_name, guest_id):
    end = ( src, guestname, session_id, region_name, guest_id, callback ) ->
        send_request "end", src, [ guestname, session_id, region_name, guest_id ], parserEndReturn, callback
        true

    #def info(self, username, session_id, region_name, guest_id=None):
    info = ( src, username, session_id, region_name, guest_id=null, callback ) ->
        send_request "info", src, [ username, session_id, region_name, guest_id ], parserInfoReturn, callback
        true


    #############################################################
    #public
    invite                       : invite
    cancel                       : cancel
    access                       : access
    end                          : end
    info                         : info

