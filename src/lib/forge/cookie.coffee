define [ 'jquery', 'MC', 'constant' ], ( $, MC, constant ) ->

	setCookie = ( result ) ->


		if document.domain.indexOf('madeiracloud.com') != -1
			#domain is *.madeiracloud.com
			option = constant.COOKIE_OPTION
		else
			#domain is not *.madeiracloud.com, maybe localhost
			option = constant.LOCAL_COOKIE_OPTION


		#set cookies
		$.cookie 'userid',      result.userid,      option
		$.cookie 'usercode',    result.usercode,    option
		$.cookie 'session_id',  result.session_id,  option
		$.cookie 'region_name', result.region_name, option
		$.cookie 'email',       result.email,       option
		$.cookie 'has_cred',    result.has_cred,    option
		$.cookie 'username',    MC.base64Decode( result.usercode ), option
		$.cookie 'account_id',	result.account_id,  option

	deleteCookie = ->

		if document.domain.indexOf('madeiracloud.com') != -1
			#domain is *.madeiracloud.com
			option = constant.COOKIE_OPTION
		else
			#domain is not *.madeiracloud.com, maybe localhost
			option = constant.LOCAL_COOKIE_OPTION


		#delete cookies
		$.cookie 'userid',      '', option
		$.cookie 'usercode',    '', option
		$.cookie 'session_id',  '', option
		$.cookie 'region_name', '', option
		$.cookie 'email',       '', option
		$.cookie 'has_cred',    '', option
		$.cookie 'username',    '', option
		$.cookie 'account_id',	'', option

	setCred = ( result ) ->

		if document.domain.indexOf('madeiracloud.com') != -1
			#domain is *.madeiracloud.com
			option = constant.COOKIE_OPTION
		else
			#domain is not *.madeiracloud.com, maybe localhost
			option = constant.LOCAL_COOKIE_OPTION


		$.cookie 'has_cred', result, option


	setIDECookie = ( result ) ->

		if document.domain.indexOf('madeiracloud.com') != -1
			#domain is *.madeiracloud.com
			option = constant.COOKIE_OPTION
		else
			#domain is not *.madeiracloud.com, maybe localhost
			option = constant.LOCAL_COOKIE_OPTION


		madeiracloud_ide_session_id = [
			result.userid,
			result.usercode,
			result.session_id,
			result.region_name,
			result.email,
			result.has_cred,
			result.account_id
		]

		$.cookie 'madeiracloud_ide_session_id', MC.base64Encode( JSON.stringify madeiracloud_ide_session_id ), option
		null

	getIDECookie = ->

		result = null

		madeiracloud_ide_session_id = $.cookie 'madeiracloud_ide_session_id'
		if madeiracloud_ide_session_id
			try
				result = JSON.parse ( MC.base64Decode madeiracloud_ide_session_id )
			catch err
				result = null

		if result and $.type result == "array" and result.length == 7
			{
				userid      : result[0] ,
				usercode    : result[1] ,
				session_id  : result[2] ,
				region_name : result[3] ,
				email       : result[4] ,
				has_cred    : result[5] ,
				account_id	: result[6] ,
			}
		else
			null


	checkAllCookie = ->

		if $.cookie('username') and $.cookie('userid') and $.cookie('usercode') and $.cookie('session_id') and $.cookie('region_name') and $.cookie('has_cred') and $.cookie('email') and $.cookie('account_id')
			true
		else
			false

	clearV2Cookie = ( path ) ->
		#for patch
		option = { path: path }


		$.each $.cookie(), ( key, cookie_name ) ->
			$.removeCookie cookie_name	, option
			null


	clearInvalidCookie = ( ) ->
		#for patch
		option = { domain: 'ide.madeiracloud.com', path: '/' }

		$.each $.cookie(), ( key, cookie_name ) ->
			$.removeCookie cookie_name	, option
			null


	getCookieByName = ( cookie_name ) ->

		$.cookie cookie_name


	setCookieByName = ( cookie_name, value ) ->

		if document.domain.indexOf('madeiracloud.com') != -1
			#domain is *.madeiracloud.com
			option = constant.COOKIE_OPTION
		else
			#domain is not *.madeiracloud.com, maybe localhost
			option = constant.LOCAL_COOKIE_OPTION


		$.cookie cookie_name, value, option


	#public
	setCookie    : setCookie
	deleteCookie : deleteCookie
	setIDECookie : setIDECookie
	getIDECookie : getIDECookie
	setCred      : setCred
	checkAllCookie : checkAllCookie
	clearV2Cookie  : clearV2Cookie
	clearInvalidCookie : clearInvalidCookie
	getCookieByName : getCookieByName
	setCookieByName : setCookieByName

