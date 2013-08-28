###

define([ 'MC','jquery' ], function( MC, $ ) {

	MC.login = function ( event )
	{
		event.preventDefault();

		MC.api({
			url: '/session/',
			method: 'login',
			data: [
				$('#login_user').val(),
				$('#login_password').val()
			],
			success: function(data, status)
			{
				if (status === 0)
				{
					$.cookie('user_name', data[1], { expires: 3600 });
					$.cookie('session_id', data[2], { expires: 3600 });

					location = 'map.html';
				}
				else
				{
					alert(data);
					$('#login_form')[0].reset();
				}
			}
		});

		return false;
	};

	return {
		ready : function () {
			$('#login_form').submit(MC.login);
		}
	};

});
###

define [ 'jquery', 'handlebars',
         'MC', 'session_model',
         'i18n!/nls/lang.js',
         'text!./js/login/template.html'
], ( $, Handlebars, MC, session_model, lang, template ) ->


	setMadeiracloudIDESessionID = ( result ) ->

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

	#private method
	MC.login = ( event ) ->

		event.preventDefault()

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

		#invoke session.login api
		session_model.login { sender : this }, username, password

		#login return handler (dispatch from service/session/session_model)
		session_model.once 'SESSION_LOGIN_RETURN', ( forge_result ) ->

			if !forge_result.is_error
				#login succeed

				result = forge_result.resolved_data

				#set cookies
				$.cookie 'userid',      result.userid,      { expires: 1 }
				$.cookie 'usercode',    result.usercode,    { expires: 1 }
				$.cookie 'session_id',  result.session_id,  { expires: 1 }
				$.cookie 'region_name', result.region_name, { expires: 1 }
				$.cookie 'email',       result.email,       { expires: 1 }
				$.cookie 'has_cred',    result.has_cred,    { expires: 1 }
				$.cookie 'username',    username,           { expires: 1 }
				$.cookie 'account_id',	result.account_id,  { expires: 1 }

				#set madeiracloud_ide_session_id
				setMadeiracloudIDESessionID result

				#redirect to page ide.html
				window.location.href = 'ide.html'

				return true

			else
				#login failed
				#alert forge_result.error_message
				event.preventDefault()
				$( '.error-msg'     ).removeClass 'show'
				$( '.control-group' ).first().removeClass 'error'
				$( '#error-msg-1'   ).addClass 'show'

				return false

	#public object
	ready : () ->
		#i18n
		Handlebars.registerHelper 'i18n', ( text ) ->
			new Handlebars.SafeString lang.login[ text ]
		#
		$( '#container' ).html Handlebars.compile template
		#
		$( '#login-btn' ).removeAttr 'disabled'
		$( '#login-btn' ).addClass 'enabled'
		$( '#login-form' ).submit( MC.login )
