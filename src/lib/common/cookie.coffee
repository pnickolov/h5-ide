define [ 'MC' ], ( MC ) ->

	COOKIE_OPTION =
		expires : 30
		path    : '/'

	setCookie = ( result ) ->
		deleteCookie()

		result.username = MC.base64Decode( result.usercode )
		for key, value of result
			$.cookie key, value, COOKIE_OPTION

		# Set a cookie for WWW
		$.cookie "has_session", !!session_info.session_id, {
			domain  : window.location.hostname.replace("ide", "")
			path    : "/"
			expires : 30
		}
		null

	deleteCookie = ->
		domain = { "domain" : window.location.hostname.replace("ide", "") }
		for ckey, cValue of $.cookie()
			$.removeCookie ckey, domain
			$.removeCookie ckey
		null

	setCred = ( result ) ->
		$.cookie 'has_cred', result, COOKIE_OPTION

	getCookieByName = ( cookie_name ) ->
		$.cookie cookie_name


	setCookieByName = ( cookie_name, value ) ->
		$.cookie cookie_name, value, COOKIE_OPTION

	#public
	setCookie          : setCookie
	deleteCookie       : deleteCookie
	setCred            : setCred
	getCookieByName    : getCookieByName
	setCookieByName    : setCookieByName
