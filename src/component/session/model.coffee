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

					#set cookies
					#$.cookie 'userid',      result.userid,          { expires: 1 }
					#$.cookie 'usercode',    result.usercode,        { expires: 1 }
					#$.cookie 'session_id',  result.session_id,      { expires: 1 }
					#$.cookie 'region_name', result.region_name,     { expires: 1 }
					#$.cookie 'email',       result.email,           { expires: 1 }
					#$.cookie 'has_cred',    result.has_cred,        { expires: 1 }
					#$.cookie 'username',    $.cookie( 'username' ), { expires: 1 }

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

		#_setMadeiracloudIDESessionID : ( result ) ->
		#
		#	madeiracloud_ide_session_id = [
		#		result.userid,
		#		result.usercode,
		#		result.session_id,
		#		result.region_name,
		#		result.email,
		#		result.has_cred
		#	]
		#
		#	$.cookie 'madeiracloud_ide_session_id', MC.base64Encode( JSON.stringify madeiracloud_ide_session_id ), {
		#		path: '/',
		#		#domain: '.madeiracloud.com', #temp comment
		#		expires: 1
		#	}
		#
		#	null

	}

	return SessionModel