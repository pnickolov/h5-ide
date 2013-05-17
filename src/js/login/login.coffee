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

define [ 'MC', 'session_model' ,'jquery'], ( MC, session_model, $ ) ->

	MC.login = ( event ) ->

		event.preventDefault()

		username = $( '#login_user' ).val()
		password = $( '#login_password' ).val()

		#invoke session.login api
		session_model.login(username, password)

		#login return handler (dispatch from service/forge/session/session_model)
		session_model.on 'login_return', ( forge_result_vo ) ->

			if !forge_result_vo.is_error
			#login succeed

				result = forge_result_vo.resolved_data

				$.cookie 'user_name',  result.usercode,   { expires: 3600 }
				$.cookie 'session_id', result.session_id, { expires: 3600 }

				#redirect to page ide.html
				window.location.href = 'ide.html'

				true

			else
			#login failed
				alert forge_result_vo.resolved_message

				false

		true

	ready : () ->
		$( '#login_form' ).submit( MC.login )