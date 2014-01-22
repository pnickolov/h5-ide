define [ 'MC',
		'lib/common/cookie',
		'lib/common/other',
		'lib/aws/convert',
], ( MC, cookie, other, convert_handler ) ->

	MC.common = {
		cookie : cookie
		other  : other
		convert : convert_handler
	}