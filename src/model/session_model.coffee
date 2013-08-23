#*************************************************************************************
#* Filename     : session_model.coffee
#* Creator      : gen_model.sh
#* Create date  : 2013-06-05 10:35:03
#* Description  : model know service
#* Action       : 1.define vo
#*                2.invoke api by service
#*                3.dispatch event to controller
# ************************************************************************************
# (c)Copyright 2012 Madeiracloud  All Rights Reserved
# ************************************************************************************

define [ 'backbone', 'underscore', 'session_service', 'base_model' ], ( Backbone, _, session_service, base_model ) ->

    SessionModel = Backbone.Model.extend {

        ###### vo (declare variable) ######
        defaults : {
            vo : {}
        }

        initialize : ->
            _.extend this, base_model

        ###### api ######
        #login api (define function)
        login : ( src, username, password ) ->

            me = this

            src.model = me

            session_service.login src, username, password, ( forge_result ) ->

                if !forge_result.is_error
                #login succeed

                    session_info = forge_result.resolved_data

                    #set vo


                else
                #login failed

                    console.log 'session.login failed, error is ' + forge_result.error_message
                    me.pub forge_result

                #dispatch event (dispatch event whenever login succeed or failed)
                if src.sender and src.sender.trigger then src.sender.trigger 'SESSION_LOGIN_RETURN', forge_result else me.trigger 'SESSION_LOGIN_RETURN', forge_result


        #logout api (define function)
        logout : ( src, username, session_id ) ->

            me = this

            src.model = me

            session_service.logout src, username, session_id, ( forge_result ) ->

                if !forge_result.is_error
                #logout succeed

                    session_info = forge_result.resolved_data

                    #set vo


                else
                #logout failed

                    console.log 'session.logout failed, error is ' + forge_result.error_message

                #dispatch event (dispatch event whenever login succeed or failed)
                if src.sender and src.sender.trigger then src.sender.trigger 'SESSION_LOGOUT_RETURN', forge_result


        #set_credential api (define function)
        set_credential : ( src, username, session_id, access_key, secret_key, account_id=null ) ->

            me = this

            src.model = me

            session_service.set_credential src, username, session_id, access_key, secret_key, account_id, ( forge_result ) ->

                if !forge_result.is_error
                #set_credential succeed

                    session_info = forge_result.resolved_data

                    #set vo


                else
                #set_credential failed

                    console.log 'session.set_credential failed, error is ' + forge_result.error_message

                #dispatch event (dispatch event whenever login succeed or failed)
                if src.sender and src.sender.trigger then src.sender.trigger 'SESSION_SET__CREDENTIAL_RETURN', forge_result


        #guest api (define function)
        guest : ( src, guest_id, guestname ) ->

            me = this

            src.model = me

            session_service.guest src, guest_id, guestname, ( forge_result ) ->

                if !forge_result.is_error
                #guest succeed

                    session_info = forge_result.resolved_data

                    #set vo


                else
                #guest failed

                    console.log 'session.guest failed, error is ' + forge_result.error_message

                #dispatch event (dispatch event whenever login succeed or failed)
                if src.sender and src.sender.trigger then src.sender.trigger 'SESSION_GUEST_RETURN', forge_result



    }

    #############################################################
    #private (instantiation)
    session_model = new SessionModel()

    #public (exposes methods)
    session_model

