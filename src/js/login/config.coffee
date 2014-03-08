
version  = '130830.1912'
language = 'en-us'
current_jquery = if /msie (9|8|7|6)/ig.test(navigator.userAgent.toLowerCase()) then '//code.jquery.com/jquery-1.10.2.min' else '//code.jquery.com/jquery-2.0.3.min'

require.config {

	baseUrl               : './'

	waitSeconds           : 30

	deps                  : [ 'main' ]

	locale                : language

	urlArgs               : 'v=' + version

	paths                 :

		#main
		'main'            : 'js/login/main'

		#vender
		'jquery'          : [ current_jquery , 'vender/jquery/jquery' ]
		'underscore'      : 'vender/underscore/underscore'
		'backbone'        : 'vender/backbone/backbone'
		'handlebars'      : 'vender/handlebars/handlebars'

		'domReady'        : 'vender/requirejs/domReady'
		'i18n'            : 'vender/requirejs/i18n'
		'text'            : 'vender/requirejs/text'

		#
		'crypto'          : 'vender/crypto-js/hmac-sha256'

		#core lib
		'MC'              : 'js/MC.core'

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

		'common_handle'    : 'lib/common/main'

		'event'           : 'lib/ide_event'

		'MC.canvas.constant' : 'lib/MC.canvas.constant'

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
			deps          : [ 'jquery', 'constant' ]
			exports       : 'MC'

		'main'            :
			deps          : [ 'jquery' ]

}

#requirejs.onError = ( err ) ->
#    console.log 'error type: ' + err.requireType + ', modules: ' + err.requireModules
