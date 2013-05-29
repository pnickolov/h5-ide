
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

	baseUrl               : './'

	deps                  : [ 'js/login/main' ]

	paths                 :

		#vender
		'jquery'          : 'vender/jquery/jquery'
		'underscore'      : 'vender/underscore/underscore'
		'backbone'        : 'vender/backbone/backbone'

		'domReady'        : 'vender/requirejs/domReady'

		#core lib
		'MC'              : 'lib/MC.core'

		#common lib
		'constant'        : 'lib/constant'

		#result_vo
		'result_vo'       : 'service/result_vo'

		#service
		'session_vo'      : 'service/session/session_vo'
		'session_parser'  : 'service/session/session_parser'
		'session_service' : 'service/session/session_service'

		#model
		'session_model'   : 'model/session_model'

		#login
		'login'           : 'js/login/login'

	shim                  :

		'jquery'          :
			exports       : '$'

		'underscore'      :
			exports       : '_'

		'backbone'        :
			deps          : [ 'underscore', 'jquery' ]
			exports       : 'Backbone'

		'MC'              :
			deps          : [ 'jquery','constant' ]
			exports       : 'MC'

}