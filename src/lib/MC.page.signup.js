var signup = {
	verification: {
		username: function ()
		{
			var value = $('#register-username').val(),
				status = $('#username-verification-status');

			status.removeClass('error-status');

			if (value.trim() !== '')
			{
				if (/[^A-Za-z0-9\_]{1}/.test(value) !== true)
				{
					status.show().text('This username is available.');

					return true;
				}
				else
				{
					status.addClass('error-status').show().text('User name not matched.');
					
					return false;
				}
			}
			else
			{
				status.addClass('error-status').show().text('User name is required.');
				
				return false;
			}
		},
		password: function ()
		{
			var value = $('#register-password').val().trim(),
				status = $('#password-verification-status');

			status.removeClass('error-status');
			//signup.verification.confirm_password();

			if (value !== '')
			{
				if (
					value.length > 6// &&
					///[A-Z]{1}/.test(value) &&
					///[0-9]{1}/.test(value)
				)
				{
					status.show().text('This password is OK.');
					
					return true;
				}
				else
				{
					status.addClass('error-status').show().text('This password is too weak.');
					
					return false;
				}
			}
			else
			{
				status.addClass('error-status').show().text('Password is required.');

				return false;
			}
		},
		// confirm_password: function ()
		// {
		// 	var value = $('#register-confirm-password').val().trim(),
		// 		status = $('#confirm-password-verification-status');

		// 	status.removeClass('error-status');

		// 	if (value !== '' && value === $('#register-password').val())
		// 	{
		// 		status.show().text('Password matched.');

		// 		return true;
		// 	}
		// 	else
		// 	{
		// 		status.addClass('error-status').show().text('Password not matched.');

		// 		return false;
		// 	}
		// },
		email: function ()
		{
			var value = $('#register-email').val().trim(),
				status = $('#email-verification-status');

			status.removeClass('error-status');

			if (value !== '' && /\w+@[0-9a-zA-Z_]+?\.[a-zA-Z]{2,6}/.test(value))
			{
				status.show().text('This email is available.');
				
				return true;
			}
			else
			{
				status.addClass('error-status').show().text('It`s not an email address.');
				
				return false;
			}
		}
	},
	submit: function (event)
	{
		if (
			signup.verification.username() &&
			signup.verification.password() &&
			//signup.verification.confirm_password() &&
			signup.verification.email()
		)
		{
			return true;
		}
		else
		{
			return false;
		}
	}
}

$(document).ready(function ()
{
	$('#register-username').on('keyup', signup.verification.username);
	$('#register-email').on('keyup', signup.verification.email);
	$('#register-password').on('keyup', signup.verification.password);
	//$('#register-confirm-password').on('keyup', signup.verification.confirm_password);

	$('#register-form').on('submit', signup.submit);
});