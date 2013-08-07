
require.config {

	baseUrl               : './'

	waitSeconds           : 30

	deps                  : [ 'js/login/main' ]

	locale                : 'en-us'

	paths                 :

		#vender
		'jquery'          : 'vender/jquery/jquery'
		'underscore'      : 'vender/underscore/underscore'
		'backbone'        : 'vender/backbone/backbone'

		'domReady'        : 'vender/requirejs/domReady'
		'i18n'            : 'vender/requirejs/i18n'

		#core lib
		'MC'              : 'lib/MC.core'

		#common lib
		'constant'        : 'lib/constant'

		#result_vo
		'result_vo'       : 'service/result_vo'

		#service
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

#requirejs.onError = ( err ) ->
#    console.log 'error type: ' + err.requireType + ', modules: ' + err.requireModules
