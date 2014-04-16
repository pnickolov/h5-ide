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
		$.cookie 'is_invitated',result.is_invitated,COOKIE_OPTION

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
		$.cookie 'is_invitated','', COOKIE_OPTION

	setCred = ( result ) ->
		$.cookie 'has_cred', result, COOKIE_OPTION

	setIDECookie = ( result ) ->
		madeiracloud_ide_session_id = [
			result.usercode,
			result.email,
			result.session_id,
			result.account_id,
			result.mod_repo,
			result.mod_tag,
			result.state,
			result.has_cred,
			result.is_invitated
		]
		null

	getCookieByName = ( cookie_name ) ->
		$.cookie cookie_name


	setCookieByName = ( cookie_name, value ) ->
		$.cookie cookie_name, value, COOKIE_OPTION

	#public
	setCookie          : setCookie
	deleteCookie       : deleteCookie
	setIDECookie       : setIDECookie
	setCred            : setCred
	getCookieByName    : getCookieByName
	setCookieByName    : setCookieByName
