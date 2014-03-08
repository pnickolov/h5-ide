
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
		'main'            : 'js/register/main'
		'router'          : 'js/register/router'
		'register'        : 'module/register/main'
		'reg_model'       : 'module/register/model'
		'reg_view'        : 'module/register/view'

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

		#
		'base_main'       : 'module/base/base_main'

		#
		'event'           : 'lib/ide_event'

		#
		'UI.notification'    : 'ui/UI.notification'

		#core lib
		'MC'              : 'js/MC.core'

		#common lib
		'constant'        : 'lib/constant'

		#
		'base_model'      : 'model/base_model'
		'account_model'   : 'model/account_model'
		'account_service' : 'service/account/account_service'
		'session_model'   : 'model/session_model'
		'session_service' : 'service/session/session_service'

		#result_vo
		'result_vo'       : 'service/result_vo'

		#forge handle
		'common_handle'    : 'lib/common/main'

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

		'register'        :
			deps          : [ 'reg_view', 'reg_model', 'MC' ]

		'main'            :
			deps          : [ 'jquery' ]
}

#requirejs.onError = ( err ) ->
#    console.log 'error type: ' + err.requireType + ', modules: ' + err.requireModules
