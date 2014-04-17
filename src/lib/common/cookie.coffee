define [ 'MC' ], ( MC ) ->

	COOKIE_OPTION =
		expires : 30
		path    : '/'

	setCookie = ( result ) ->
		result.username = MC.base64Decode( result.usercode )
		for key, value of result
        $.cookie key, value, COOKIE_OPTION
    null

	deleteCookie = ->
		$.cookie 'usercode',    '', COOKIE_OPTION
		$.cookie 'username',    '', COOKIE_OPTION
		$.cookie 'user_hash',   '', COOKIE_OPTION
		$.cookie 'email',       '', COOKIE_OPTION
		$.cookie 'session_id',  '', COOKIE_OPTION
		$.cookie 'account_id',	'', COOKIE_OPTION
		$.cookie 'mod_repo',    '', COOKIE_OPTION
		$.cookie 'mod_tag',     '', COOKIE_OPTION
		$.cookie 'state',       '', COOKIE_OPTION
		$.cookie 'has_cred',    '', COOKIE_OPTION

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
