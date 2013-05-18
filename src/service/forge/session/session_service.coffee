###
Description:
	service know back-end api
Action:
	1.invoke MC.api (send url, method, data)
	2.invoke parser
	3.invoke callback
###

define [ 'MC', 'session_parser', 'result_vo' ], ( MC, session_parser, result_vo ) ->

	URL = '/session/'

	#def login(self, username, password):
	login = ( username, password, callback ) ->

		#check callback
		if callback is null
			console.log "session_service.login callback is null"
			return false

		try

			param = [ username, password ]

			MC.api {
				url     : URL
				method  : 'login'
				data    : param
				success : ( result, return_code ) ->

					#resolve result
					result_vo.forge_result = session_parser.parseLoginResult result, return_code, param

					callback result_vo.forge_result

				error : ( result, return_code ) ->

					result_vo.forge_result.return_code      = return_code
					result_vo.forge_result.is_error         = true
					result_vo.forge_result.resolved_message = result.toString()

					callback result_vo.forge_result
			}

		catch error
			console.log "session_service.login error:" + error.toString()


		true
	# end of login()

	#def logout(self, username, session_id):
	logout = ( callback, username, session_id ) ->
		alert 'logout'

	#def set_credential(self, username, session_id, access_key, secret_key, account_id=None):
	setCredential = ( callback, username, session_id, access_key, secret_key, account_id = null ) ->
		alert 'setCredential'

	#def guest(self, guest_id, guestname):
	guest = ( callback, guest_id, guestname ) ->
		alert 'guest'

	#public
	login          : login
	logout         : logout
	setCredential  : setCredential
	guest          : guest
