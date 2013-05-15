
###
//config
require.config({

	baseUrl         : './',

	deps            : [ 'js/login/main' ],

	paths           : {

		'jquery'    : 'vender/jquery/jquery',

		'MC'        : 'lib/MC.core',

		'login'     : 'js/login/login'

	},

	shim            : {

		'jquery'    : {
			exports : '$'
		},
		
		'MC'        : {
			deps    : [ 'jquery' ],
			exports : 'MC'
		}
	}

});
###

require.config {

	baseUrl         : './'

	deps            : [ 'js/login/main' ]

	paths           :

		#vender
		'jquery'    : 'vender/jquery/jquery'

		#cor lib
		'MC'        : 'lib/MC.core'

		#service
		'service'   : 'service/forge/session/session'
		'vo'        : 'service/forge/session/session_vo'
		'parser'    : 'service/forge/session/session_parser'

		#login
		'login'     : 'js/login/login'

	shim            :

		'jquery'    :
			exports : '$'

		'MC'        :
			deps    : [ 'jquery' ]
			exports : 'MC'

}