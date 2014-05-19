define [ 'MC',
		'lib/common/other',
		'lib/common/convert',
], ( MC, other, convert_handler ) ->

	MC.common = {
		other  : other
		convert : convert_handler
	}

	MC.common
