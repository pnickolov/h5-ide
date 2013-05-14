
define [ 'MC', 'vo', 'parser' ], ( MC, vo, parser ) ->

	login = ( url, method, param, callback ) ->
		
		MC.api {
			url     : url
			method  : method
			data    : param
			success : ( result, status ) ->

				vo.user_vo = parser.parser_user_vo( result )
				
				callback vo.user_vo, status, param
		}

	logout = () ->
		alert 'logout'

	set_credential = () ->
		alert 'set_credential'

	guest = () ->
		alert 'guest'

	#public
	login          : login
	logout         : logout
	set_credential : set_credential
	guest          : guest