define [ 'jquery', 'MC', 'constant' ], ( $, MC, constant ) ->

	setCookie = ( result ) ->

		#set cookies
		$.cookie 'userid',      result.userid,      { expires: 1 }
		$.cookie 'usercode',    result.usercode,    { expires: 1 }
		$.cookie 'session_id',  result.session_id,  { expires: 1 }
		$.cookie 'region_name', result.region_name, { expires: 1 }
		$.cookie 'email',       result.email,       { expires: 1 }
		$.cookie 'has_cred',    result.has_cred,    { expires: 1 }
		$.cookie 'username',    MC.base64Decode( result.usercode ), { expires: 1 }
		$.cookie 'account_id',	result.account_id,  { expires: 1 }

	deleteCookie = ->

		#delete cookies
		$.cookie 'userid',      null, { expires: 1 }
		$.cookie 'usercode',    null, { expires: 1 }
		$.cookie 'session_id',  null, { expires: 1 }
		$.cookie 'region_name', null, { expires: 1 }
		$.cookie 'email',       null, { expires: 1 }
		$.cookie 'has_cred',    null, { expires: 1 }
		$.cookie 'username',    null, { expires: 1 }
		$.cookie 'account_id',	null, { expires: 1 }

	setIDECookie = ( result ) ->

		madeiracloud_ide_session_id = [
			result.userid,
			result.usercode,
			result.session_id,
			result.region_name,
			result.email,
			result.has_cred,
			result.account_id
		]

		$.cookie 'madeiracloud_ide_session_id', MC.base64Encode( JSON.stringify madeiracloud_ide_session_id ), {
			path: '/',
			#domain: '.madeiracloud.com', #temp comment
			expires: 1
		}
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

	#public
	setCookie    : setCookie
	deleteCookie : deleteCookie
	setIDECookie : setIDECookie
	getIDECookie : getIDECookie
