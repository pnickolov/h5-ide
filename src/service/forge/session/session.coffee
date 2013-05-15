
define [ 'MC', 'vo', 'parser' ], ( MC, VO, Parser ) ->

	login = ( url, method, param, callback ) ->
		
		MC.api {
			url     : url
			method  : method
			data    : param
			success : ( result, status ) ->

				VO.user_vo = Parser.parserUserVO result
				
				callback VO.user_vo, status, param
		}

	logout = () ->
		alert 'logout'

	setCredential = () ->
		alert 'set_credential'

	guest = () ->
		alert 'guest'

	#public
	login          : login
	logout         : logout
	setCredential  : setCredential
	guest          : guest