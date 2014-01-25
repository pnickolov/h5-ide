define [ 'MC',
		'lib/common/cookie',
		'lib/common/other',
		'lib/common/convert',
], ( MC, cookie, other, convert_handler ) ->

	MC.common = {
		cookie : cookie
		other  : other
		convert : convert_handler
	}
