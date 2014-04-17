define [ 'MC' ], ( MC ) ->

	COOKIE_OPTION =
		expires : 30
		path    : '/'

	setCookie = ( result ) ->
		$.cookie 'usercode',    result.usercode,    COOKIE_OPTION
		$.cookie 'username',    MC.base64Decode( result.usercode ), COOKIE_OPTION
		$.cookie 'email',       result.email,       COOKIE_OPTION
		$.cookie 'session_id',  result.session_id,  COOKIE_OPTION
		$.cookie 'account_id',  result.account_id,  COOKIE_OPTION
		$.cookie 'mod_repo',    result.mod_repo,    COOKIE_OPTION
		$.cookie 'mod_tag',     result.mod_tag,     COOKIE_OPTION
		$.cookie 'state',       result.state,       COOKIE_OPTION
		$.cookie 'has_cred',    result.has_cred,    COOKIE_OPTION

	deleteCookie = ->
		$.cookie 'usercode',    '', COOKIE_OPTION
		$.cookie 'username',    '', COOKIE_OPTION
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
