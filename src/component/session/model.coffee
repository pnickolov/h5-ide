#############################
#  View Mode for component/session
#############################

define [ 'session_model', 'forge_handle'
		 'backbone', 'jquery', 'underscore', 'MC'
], ( session_model, forge_handle ) ->

	SessionModel = Backbone.Model.extend {

		relogin : ( password ) ->
			console.log 'relogin, password = ' + password
			me = this

			#invoke session.login api
			session_model.login { sender : this }, $.cookie( 'username' ), password

			#login return handler (dispatch from service/session/session_model)
			this.once 'SESSION_LOGIN_RETURN', ( forge_result ) ->
				console.log 'SESSION_LOGIN_RETURN'

				if !forge_result.is_error
					#login succeed

					result = forge_result.resolved_data

					#set cookie
					forge_handle.cookie.setCookie result

					#set madeiracloud_ide_session_id
					#@_setMadeiracloudIDESessionID result
					forge_handle.cookie.setIDECookie result

					me.trigger 'RE_LOGIN_SCUCCCESS'

				else
					console.log 'Authentication failed.'
					me.trigger 'RE_LOGIN_FAILED'

				null

	}

	return SessionModel