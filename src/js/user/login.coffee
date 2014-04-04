define [ 'jquery', 'handlebars',
		 'MC', 'session_model',
		 'i18n!nls/lang.js',
		 'js/user/logintemplate',
		 'common_handle', 'crypto'
], ( $, Handlebars, MC, session_model, lang, template, common_handle ) ->

	MC.login = ( event ) ->

		event.preventDefault()

		#remove
		$( '#error-msg-1' ).removeClass 'show'
		$( '#error-msg-2' ).removeClass 'show'
		$( '.control-group' ).removeClass 'error'

		username = $( '#login-user' ).val()
		password = $( '#login-password' ).val()

		#Email is empty
		if username is ''
			event.preventDefault()
			$( '.error-msg'     ).removeClass 'show'
			$( '.control-group' ).first().removeClass 'error'
			$( '#error-msg-2'   ).addClass 'show'
			$( '.control-group' ).first().addClass 'error'
			return false

		$( '#login-btn'   ).attr( 'value', lang.login.login_waiting )
		$( '#login-btn'   ).attr( 'disabled', true )

		#invoke session.login api
		session_model.login { sender : this }, username, password

		#login return handler (dispatch from service/session/session_model)
		session_model.once 'SESSION_LOGIN_RETURN', ( forge_result ) ->

			# 500
			MC.common.other.verify500 forge_result

			if !forge_result.is_error
				#login succeed

				result = forge_result.resolved_data

				#clear old cookie
				common_handle.cookie.deleteCookie()

				#set cookies
				common_handle.cookie.setCookie result

				#set madeiracloud_ide_session_id
				#setMadeiracloudIDESessionID result
				common_handle.cookie.setIDECookie result

				#set email
				localStorage.setItem 'email',     MC.base64Decode( common_handle.cookie.getCookieByName( 'email' ))
				localStorage.setItem 'user_name', common_handle.cookie.getCookieByName( 'username' )
				intercom_sercure_mode_hash = () ->
					intercom_api_secret = '4tGsMJzq_2gJmwGDQgtP2En1rFlZEvBhWQWEOTKE'
					hash = CryptoJS.HmacSHA256( MC.base64Decode($.cookie('email')), intercom_api_secret )
					console.log 'hash.toString(CryptoJS.enc.Hex) = ' + hash.toString(CryptoJS.enc.Hex)
					return hash.toString CryptoJS.enc.Hex
				localStorage.setItem 'user_hash', intercom_sercure_mode_hash()

				window.location.href = "/"


				return true

			else
				#login failed
				#alert forge_result.error_message
				event.preventDefault()
				$( '.error-msg'     ).removeClass 'show'
				$( '.control-group' ).first().removeClass 'error'
				$( '#error-msg-1'   ).addClass 'show'
				#
				$( '#login-btn'   ).attr( 'value', 'Log In' )
				$( '#login-btn'   ).attr( 'disabled', false )

				return false

	#public object
	ready : () ->
		data =
			english: $.cookie( 'lang' ) is 'en-us'

		$( '#main-body' ).html template data
		$( '#login-btn'   ).removeAttr 'disabled'
		$( '#login-btn'   ).addClass 'enabled'
		$( '#login-form'  ).submit( MC.login )
		$( '#footer .version' ).text 'Version ' + version
		$('#footer .lang a').click ( ev ) ->
			$.cookie 'lang', $(this).data 'lang'
			MC.storage.set 'language', $(this).data 'lang'
			window.location.reload()
			false

		return true
