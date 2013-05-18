###
Description:
	model know service interface, and provide operation to vo
Action:
	1.define vo
	2.provide encapsulation of api for controller
	3.dispatch event to controller
###

define [ 'backbone', 'session_service', 'session_vo'], ( Backbone, session_service, session_vo ) ->

    SessionModel = Backbone.Model.extend {

        #vo (declare variable)
        defaults : {
            vo : session_vo.session_info
        }

        #login api (define function)
        login : (username, password) ->

            me = this

            session_service.login username, password, ( forge_result ) ->

                if !forge_result.is_error
                #login succeed

                    session_info = forge_result.resolved_data

                    #set vo
                    me.set 'vo.usercode'   , session_info.usercode
                    me.set 'vo.region_name', session_info.region_name

                else
                #login failed

                    console.log 'login failed, error is ' + forge_result.error_message

                #dispatch event (dispatch to js/login/login whenever login succeed or failed)
                me.trigger 'SESSION_LOGIN_RETURN', forge_result

    }

    #private (instantiation)
    session_model = new SessionModel()

    #public (exposes methods)
    session_model
