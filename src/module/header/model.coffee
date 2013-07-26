#############################
#  View Mode for header
#############################

define [ 'MC', 'event', 'backbone', 'session_model' ], ( MC, ide_event, Backbone, session_model ) ->

    #private
    HeaderModel = Backbone.Model.extend {

        defaults : null


        logout : () ->

            #invoke session.logout api
            session_model.logout {sender: this}, $.cookie( 'usercode' ), $.cookie( 'session_id' )

            #logout return handler (dispatch from service/session/session_model)
            session_model.once 'SESSION_LOGOUT_RETURN', ( forge_result ) ->

                if !forge_result.is_error
                    #logout succeed

                    result = forge_result.resolved_data

                #delete cookies
                $.cookie 'userid',      null, { expires: 0 }
                $.cookie 'usercode',    null, { expires: 0 }
                $.cookie 'session_id',  null, { expires: 0 }
                $.cookie 'region_name', null, { expires: 0 }
                $.cookie 'email',       null, { expires: 0 }
                $.cookie 'has_cred',    null, { expires: 0 }

                #redirect to page login.html
                window.location.href = 'login.html'

                return false

            null

    }

    model = new HeaderModel()

    return model