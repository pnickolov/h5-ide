define [ 'jquery', 'MC', 'constant' ], ( $, MC, constant ) ->

	setCookie = ( result ) ->


		if document.domain.indexOf(MC.DOMAIN) != -1
			#domain is *.visualops.io
			option = constant.COOKIE_OPTION
		else
			#domain is not *.visualops.io, maybe localhost
			option = constant.LOCAL_COOKIE_OPTION

		#set cookies
		#$.cookie 'userid',      result.userid,      option
		#$.cookie 'region_name', result.region_name, option

		$.cookie 'usercode',    result.usercode,    option
		$.cookie 'username',    MC.base64Decode( result.usercode ), option
		$.cookie 'email',       result.email,       option
		$.cookie 'session_id',  result.session_id,  option
		$.cookie 'account_id',  result.account_id,  option
		$.cookie 'mod_repo',    result.mod_repo,    option
		$.cookie 'mod_tag',     result.mod_tag,     option
		$.cookie 'state',       result.state,       option
		$.cookie 'has_cred',    result.has_cred,    option
		$.cookie 'is_invitated',result.is_invitated,option

	deleteCookie = ->

		if document.domain.indexOf(MC.DOMAIN) != -1
			#domain is *.visualops.io
			option = constant.COOKIE_OPTION
		else
			#domain is not *.visualops.io, maybe localhost
			option = constant.LOCAL_COOKIE_OPTION

		#delete cookies
		#$.cookie 'region_name', '', option
		#$.cookie 'userid',      '', option

		$.cookie 'usercode',    '', option
		$.cookie 'username',    '', option
		$.cookie 'email',       '', option
		$.cookie 'session_id',  '', option
		$.cookie 'account_id',	'', option
		$.cookie 'mod_repo',    '', option
		$.cookie 'mod_tag',     '', option
		$.cookie 'state',       '', option
		$.cookie 'has_cred',    '', option
		$.cookie 'is_invitated','', option

		#$.cookie 'madeiracloud_ide_session_id', '', option

	setCred = ( result ) ->

		if document.domain.indexOf(MC.DOMAIN) != -1
			#domain is *.visualops.io
			option = constant.COOKIE_OPTION
		else
			#domain is not *.visualops.io, maybe localhost
			option = constant.LOCAL_COOKIE_OPTION


		$.cookie 'has_cred', result, option

	setIDECookie = ( result ) ->

		if document.domain.indexOf(MC.DOMAIN) != -1
			#domain is *.visualops.io
			option = constant.COOKIE_OPTION
		else
			#domain is not *.visualops.io, maybe localhost
			option = constant.LOCAL_COOKIE_OPTION


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

		#$.cookie 'madeiracloud_ide_session_id', MC.base64Encode( JSON.stringify madeiracloud_ide_session_id ), option
		null

	#getIDECookie = ->
	#
	#	result = null
	#
	#	madeiracloud_ide_session_id = $.cookie 'madeiracloud_ide_session_id'
	#	if madeiracloud_ide_session_id
	#		try
	#			result = JSON.parse ( MC.base64Decode madeiracloud_ide_session_id )
	#		catch err
	#			result = null
	#
	#	if result and $.type result == "array" and result.length == 8
	#		{
	#			usercode    : result[0] ,
	#			email       : result[1] ,
	#			session_id  : result[2] ,
	#			account_id  : result[3] ,
	#			mod_repo    : result[4] ,
	#			mod_tag     : result[5] ,
	#			state       : result[6] ,
	#			has_cred    : result[7] ,
	#			is_invitated: result[8] ,
	#		}
	#	else
	#		null

	checkAllCookie = ->

		if $.cookie('usercode') and $.cookie('username') and $.cookie('session_id') and $.cookie('account_id') and $.cookie('mod_repo') and $.cookie('mod_tag') and $.cookie('state') and $.cookie('has_cred') and $.cookie('is_invitated')
			true
		else
			false

	clearV2Cookie = ( path ) ->
		#for patch
		option = { path: path }


		$.each $.cookie(), ( key, cookie_name ) ->
			$.removeCookie cookie_name	, option
			null

	#clearInvalidCookie = ( ) ->
	#	#for patch
	#	option = { domain: 'ide.visualops.io', path: '/' }
	#
	#	$.each $.cookie(), ( key, cookie_name ) ->
	#		$.removeCookie cookie_name	, option
	#		null

	getCookieByName = ( cookie_name ) ->

		$.cookie cookie_name


	setCookieByName = ( cookie_name, value ) ->

		if document.domain.indexOf(MC.DOMAIN) != -1
			#domain is *.visualops.io
			option = constant.COOKIE_OPTION
		else
			#domain is not *.visualops.io, maybe localhost
			option = constant.LOCAL_COOKIE_OPTION


		$.cookie cookie_name, value, option

	#public
	setCookie          : setCookie
	deleteCookie       : deleteCookie
	setIDECookie       : setIDECookie
	#getIDECookie      : getIDECookie
	setCred            : setCred
	checkAllCookie     : checkAllCookie
	clearV2Cookie      : clearV2Cookie
	#clearInvalidCookie: clearInvalidCookie
	getCookieByName    : getCookieByName
	setCookieByName    : setCookieByName