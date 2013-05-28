#*************************************************************************************
#* Filename     : session_service.coffee
#* Creator      : gen_service.sh
#* Create date  : 2013-05-27 14:02:50
#* Description  : service know back-end api
#* Action       : 1.invoke MC.api (send url, method, data)
#*                2.invoke parser
#*                3.invoke callback
# ************************************************************************************
# (c)Copyright 2012 Madeiracloud  All Rights Reserved
# ************************************************************************************

define [ 'MC', 'session_parser', 'result_vo' ], ( MC, session_parser, result_vo ) ->

    URL = '/session/'

    #private
    send_request =  ( api_name, param_ary, parser, callback ) ->

        #check callback
        if callback is null
            console.log "session." + api_name + " callback is null"
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
            console.log "session." + method + " error:" + error.toString()


        true
    # end of send_request

    #def login(self, username, password):
    login = ( username, password, callback ) ->
        send_request "login", [ username, password ], session_parser.parserLoginReturn, callback
        true

    #def logout(self, username, session_id):
    logout = ( username, session_id, callback ) ->
        send_request "logout", [ username, session_id ], session_parser.parserLogoutReturn, callback
        true

    #def set_credential(self, username, session_id, access_key, secret_key, account_id=None):
    set_credential = ( username, session_id, access_key, secret_key, account_id=null, callback ) ->
        send_request "set_credential", [ username, session_id, access_key, secret_key, account_id ], session_parser.parserSetCredentialReturn, callback
        true

    #def guest(self, guest_id, guestname):
    guest = ( guest_id, guestname, callback ) ->
        send_request "guest", [ guest_id, guestname ], session_parser.parserGuestReturn, callback
        true


    #############################################################
    #public
    login                        : login
    logout                       : logout
    set_credential               : set_credential
    guest                        : guest

