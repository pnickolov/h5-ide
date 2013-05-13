
define [ 'MC' ], ( MC ) ->

	login = ( url, method, param, callback ) ->
		
		MC.api {
			url     : url
			method  : method
			data    : param
			success : ( result, status ) ->
				callback result, status
		}

	logout = () ->
		alert 'logout'

	set_credential = () ->
		alert 'set_credential'

	guest = () ->
		alert 'guest'

	login          : login
	logout         : logout
	set_credential : set_credential
	guest          : guest