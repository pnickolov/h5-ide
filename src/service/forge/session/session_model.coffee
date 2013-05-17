###
Description:
	model know service interface, and provide operation to vo
Action:
	1.define vo
	2.provide encapsulation of api for controller
	3.dispatch event to controller
###

define [ 'backbone', 'session_service'], ( Backbone, session_service) ->

    SessionModel = Backbone.Model.extend {

        #vo
        defaults : {
            userid      : ""
            usercode    : ""
            session_id  : ""
            region_name : ""
            email       : ""
            has_cred    : ""
        }

        #login api
        login : (username, password) ->

            me = this

            session_service.login username, password, ( forge_result_vo ) ->

                if !forge_result_vo.is_error
                #login succeed

                    user_vo = forge_result_vo.resolved_data

                    #set vo
                    me.set 'usercode', user_vo.usercode
                    me.set 'region_name', user_vo.region_name

                else
                #login failed

                    console.log 'login failed, error is ' + forge_result_vo.resolved_message

                #dispatch event (dispatch to js/login/login whenever login succeed or failed)
                me.trigger 'login_return', forge_result_vo

    }

    #private
    sessionModel = new SessionModel()

    #public
    sessionModel
