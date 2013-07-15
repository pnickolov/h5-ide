#*************************************************************************************
#* Filename     : session_service.coffee
#* Creator      : gen_service.sh
#* Create date  : 2013-06-04 15:13:08
#* Description  : service know back-end api
#* Action       : 1.invoke MC.api (send url, method, data)
#*                2.invoke parser
#*                3.invoke callback
# ************************************************************************************
# (c)Copyright 2012 Madeiracloud  All Rights Reserved
# ************************************************************************************

define [ 'MC', 'constant', 'result_vo' ], ( MC, constant, result_vo ) ->

    URL = '/session/'

    #private
    send_request =  ( api_name, src, param_ary, parser, callback ) ->

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
            console.log "session." + api_name + " error:" + error.toString()


        true
    # end of send_request

    #///////////////// Parser for login return (need resolve) /////////////////
    #private (resolve result to vo )
    resolveLoginResult = ( result ) ->
        session_info = {}

        #resolve result
        session_info.userid      = result[0]
        session_info.usercode    = result[1]
        session_info.session_id  = result[2]
        session_info.region_name = result[3]
        session_info.email       = result[4]
        session_info.has_cred    = result[5]

        #return session_info
        session_info

    #private (parser login return)
    parserLoginReturn = ( result, return_code, param ) ->

        #1.resolve return_code
        forge_result = result_vo.processForgeReturnHandler result, return_code, param

        #2.resolve return_data when return_code is E_OK
        if return_code == constant.RETURN_CODE.E_OK && !forge_result.is_error

            resolved_data = resolveLoginResult result

            forge_result.resolved_data = resolved_data


        #3.return vo
        forge_result

    # end of parserLoginReturn


    #///////////////// Parser for logout return (need resolve) /////////////////
    #private (resolve result to vo )
    resolveLogoutResult = ( result ) ->
        #resolve result
        #TO-DO

        #return session_info
        #TO-DO

    #private (parser logout return)
    parserLogoutReturn = ( result, return_code, param ) ->

        #1.resolve return_code
        forge_result = result_vo.processForgeReturnHandler result, return_code, param

        #2.resolve return_data when return_code is E_OK
        if return_code == constant.RETURN_CODE.E_OK && !forge_result.is_error

            resolved_data = resolveLogoutResult result

            forge_result.resolved_data = resolved_data


        #3.return vo
        forge_result

    # end of parserLogoutReturn


    #///////////////// Parser for set_credential return (need resolve) /////////////////
    #private (resolve result to vo )
    resolveSetCredentialResult = ( result ) ->
        #resolve result
        #TO-DO

        #return vo
        #TO-DO

    #private (parser set_credential return)
    parserSetCredentialReturn = ( result, return_code, param ) ->

        #1.resolve return_code
        forge_result = result_vo.processForgeReturnHandler result, return_code, param

        #2.resolve return_data when return_code is E_OK
        if return_code == constant.RETURN_CODE.E_OK && !forge_result.is_error

            resolved_data = resolveSetCredentialResult result

            forge_result.resolved_data = resolved_data


        #3.return vo
        forge_result

    # end of parserSetCredentialReturn


    #///////////////// Parser for guest return (need resolve) /////////////////
    #private (resolve result to vo )
    resolveGuestResult = ( result ) ->
        session_info = {}
        #resolve result
        session_info.userid         = result[0]
        session_info.usercode   = result[1]
        session_info.session_id     = result[2]
        session_info.region_name = result[3]

        #return vo
        session_info

    #private (parser guest return)
    parserGuestReturn = ( result, return_code, param ) ->

        #1.resolve return_code
        forge_result = result_vo.processForgeReturnHandler result, return_code, param

        #2.resolve return_data when return_code is E_OK
        if return_code == constant.RETURN_CODE.E_OK && !forge_result.is_error

            resolved_data = resolveGuestResult result

            forge_result.resolved_data = resolved_data


        #3.return vo
        forge_result

    # end of parserGuestReturn


    #############################################################

    #def login(self, username, password):
    login = ( src, username, password, callback ) ->
        send_request "login", src, [ username, password ], parserLoginReturn, callback
        true

    #def logout(self, username, session_id):
    logout = ( src, username, session_id, callback ) ->
        send_request "logout", src, [ username, session_id ], parserLogoutReturn, callback
        true

    #def set_credential(self, username, session_id, access_key, secret_key, account_id=None):
    set_credential = ( src, username, session_id, access_key, secret_key, account_id=null, callback ) ->
        send_request "set_credential", src, [ username, session_id, access_key, secret_key, account_id ], parserSetCredentialReturn, callback
        true

    #def guest(self, guest_id, guestname):
    guest = ( src, guest_id, guestname, callback ) ->
        send_request "guest", src, [ guest_id, guestname ], parserGuestReturn, callback
        true


    #############################################################
    #public
    login                        : login
    logout                       : logout
    set_credential               : set_credential
    guest                        : guest

