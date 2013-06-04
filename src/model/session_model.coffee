#*************************************************************************************
#* Filename     : session_model.coffee
#* Creator      : gen_model.sh
#* Create date  : 2013-06-04 09:43:35
#* Description  : model know service
#* Action       : 1.define vo
#*                2.invoke api by service
#*                3.dispatch event to controller
# ************************************************************************************
# (c)Copyright 2012 Madeiracloud  All Rights Reserved
# ************************************************************************************

define [ 'backbone', 'session_service', 'session_vo'], ( Backbone, session_service, session_vo ) ->

    SessionModel = Backbone.Model.extend {

        ###### vo (declare variable) ######
        defaults : {
            vo : session_vo.session_info
        }

        ###### api ######
        #login api (define function)
        login : ( username, password ) ->

            me = this

            session_service.login username, password, ( forge_result ) ->

                if !forge_result.is_error
                #login succeed

                    session_info = forge_result.resolved_data

                    #set vo
                    me.set 'vo.usercode'   , session_vo.session_info.usercode
                    me.set 'vo.region_name', session_vo.session_info.region_name

                else
                #login failed

                    console.log 'session.login failed, error is ' + forge_result.error_message

                #dispatch event (dispatch event whenever login succeed or failed)
                me.trigger 'SESSION_LOGIN_RETURN', forge_result


        #logout api (define function)
        logout : ( username, session_id ) ->

            me = this

            session_service.logout username, password, ( forge_result ) ->

                if !forge_result.is_error
                #logout succeed

                    session_info = forge_result.resolved_data

                    #set vo


                else
                #logout failed

                    console.log 'session.logout failed, error is ' + forge_result.error_message

                #dispatch event (dispatch event whenever login succeed or failed)
                me.trigger 'SESSION_LOGOUT_RETURN', forge_result


        #set_credential api (define function)
        set_credential : ( username, session_id, access_key, secret_key, account_id=null ) ->

            me = this

            session_service.set_credential username, password, ( forge_result ) ->

                if !forge_result.is_error
                #set_credential succeed

                    session_info = forge_result.resolved_data

                    #set vo


                else
                #set_credential failed

                    console.log 'session.set_credential failed, error is ' + forge_result.error_message

                #dispatch event (dispatch event whenever login succeed or failed)
                me.trigger 'SESSION_SET__CREDENTIAL_RETURN', forge_result


        #guest api (define function)
        guest : ( guest_id, guestname ) ->

            me = this

            session_service.guest username, password, ( forge_result ) ->

                if !forge_result.is_error
                #guest succeed

                    session_info = forge_result.resolved_data

                    #set vo


                else
                #guest failed

                    console.log 'session.guest failed, error is ' + forge_result.error_message

                #dispatch event (dispatch event whenever login succeed or failed)
                me.trigger 'SESSION_GUEST_RETURN', forge_result



    }

    #############################################################
    #private (instantiation)
    session_model = new SessionModel()

    #public (exposes methods)
    session_model

