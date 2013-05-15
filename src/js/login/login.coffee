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

define [ 'MC', 'service', 'vo' ,'jquery' ], ( MC, session, VO, $ ) ->

	MC.login = ( event ) ->
		
		event.preventDefault()

		session.login '/session/', 'login', [ $( '#login_user' ).val(), $( '#login_password' ).val() ], ( result, status ) ->

			if status is VO.STATIC.E_OK
				$.cookie 'user_name',  result.usercode,   { expires: 3600 }
				$.cookie 'session_id', result.session_id, { expires: 3600 }
				
				#alert 'login success, result.usercode = ' + result.usercode + ' ,result.session_id = ' + result.session_id

				window.location.href = 'ide.html'

				true
			else
				$( '#login_form' )[0].reset()

				alert 'login unsucess, error is ' + result

		false

	ready : () ->
		$( '#login_form' ).submit( MC.login )