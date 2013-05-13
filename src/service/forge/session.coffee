
define [ 'MC','jquery' ], ( MC, $ ) ->

	login = ( url, method, data, callback ) ->
		
		MC.api {
			url     : url
			method  : method
			data    : data
			success : ( data, status ) ->
				callback data, status
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