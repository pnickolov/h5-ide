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
         'text!/js/login/template.html'
], ( $, Handlebars, MC, session_model, lang, template ) ->

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
		session_model.login {sender: this}, username, password

		#login return handler (dispatch from service/session/session_model)
		session_model.once 'SESSION_LOGIN_RETURN', ( forge_result ) ->

			if !forge_result.is_error
				#login succeed

				result = forge_result.resolved_data

				#set cookies
				$.cookie 'userid',      result.userid,      { expires: 3600 }
				$.cookie 'usercode',    result.usercode,    { expires: 3600 }
				$.cookie 'session_id',  result.session_id,  { expires: 3600 }
				$.cookie 'region_name', result.region_name, { expires: 3600 }
				$.cookie 'email',       result.email,       { expires: 3600 }
				$.cookie 'has_cred',    result.has_cred,    { expires: 3600 }

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

	###
	setLang = () ->
		$( '#login-title > h2' ).html  lang.login.login
		$( '#login-register' ).html lang.login[ 'login-register' ] + '<a href="#" id="link-register">Register</a>'
		$( '#link-register' ).html  lang.login[ "link-register" ]
		$( '#error-msg-1' ).html    lang.login[ "error-msg-1" ]
		$( '#error-msg-2' ).html    lang.login[ "error-msg-2" ]
		$( '#link-foget' ).html     lang.login[ "link-foget" ]
		$( '#footer-info' ).html    lang.login[ "footer-info" ]
		$( '#login-btn' ).val        lang.login[ "login-btn" ]
		$( '#login-user' ).attr     'placeholder', lang.login[ "login-user" ]
		$( '#login-password' ).attr 'placeholder', lang.login[ "login-password" ]
		null
	###

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
		#
		#setLang()
