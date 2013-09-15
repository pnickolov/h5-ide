
require.config {

	baseUrl               : './'

	waitSeconds           : 30

	deps                  : [ 'main' ]

	locale                : 'en-us'

	urlArgs               : 'v=' + version

	paths                 :

		#main
		'main'            : 'js/login/main'

		#vender
		'jquery'          : [ '//code.jquery.com/jquery-2.0.3.min', 'vender/jquery/jquery' ]
		'underscore'      : 'vender/underscore/underscore'
		'backbone'        : 'vender/backbone/backbone'
		'handlebars'      : 'vender/handlebars/handlebars'

		'domReady'        : 'vender/requirejs/domReady'
		'i18n'            : 'vender/requirejs/i18n'
		'text'            : 'vender/requirejs/text'

		#
		'crypto'          : 'vender/crypto-js/hmac-sha256'

		#core lib
		'MC'              : 'lib/MC.core'

		#common lib
		'constant'        : 'lib/constant'

		#base_model
		'base_model'      : 'model/base_model'

		#result_vo
		'result_vo'       : 'service/result_vo'

		#service
		'session_service' : 'service/session/session_service'

		#model
		'session_model'   : 'model/session_model'

		#login
		'login'           : 'js/login/login'

		'forge_handle'    : 'lib/forge/main'

	shim                  :

		'jquery'          :
			exports       : '$'

		'underscore'      :
			exports       : '_'

		'backbone'        :
			deps          : [ 'underscore', 'jquery' ]
			exports       : 'Backbone'

		'handlebars'      :
			exports       : 'Handlebars'

		'MC'              :
			deps          : [ 'jquery','constant' ]
			exports       : 'MC'

}

#requirejs.onError = ( err ) ->
#    console.log 'error type: ' + err.requireType + ', modules: ' + err.requireModules
