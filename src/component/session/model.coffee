#############################
#  View Mode for component/session
#############################

define [ 'session_model', 'common_handle'
		 'backbone', 'jquery', 'underscore', 'MC'
], ( session_model, common_handle ) ->

	SessionModel = Backbone.Model.extend {

		initialize : ->

			me = this

			#login return handler (dispatch from service/session/session_model)
			@on 'SESSION_LOGIN_RETURN', ( forge_result ) ->
				console.log 'SESSION_LOGIN_RETURN'

				if !forge_result.is_error
					#login succeed

					result = forge_result.resolved_data

					#set cookie
					common_handle.cookie.setCookie result

					me.trigger 'RE_LOGIN_SCUCCCESS'

				else
					console.log 'Authentication failed.'
					me.trigger 'RE_LOGIN_FAILED'

				null

		relogin : ( password ) ->
			console.log 'relogin, password = ' + password
			#invoke session.login api
			session_model.login { sender : this }, $.cookie( 'username' ), password

	}

	return SessionModel
