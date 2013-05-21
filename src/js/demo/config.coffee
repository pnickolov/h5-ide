
###
//config
require.config({

	deps: [ "main" ],

	baseUrl: './',

	paths : {

		'backbone'     : 'vender/backbone/backbone-min',
		'underscore'   : 'vender/underscore/underscore-min',
		'jquery'       : 'vender/jquery/jquery-1.9.1.min',
		'handlebars'   : 'vender/handlebars/handlebars',

		'domReady'     : 'vender/require/domReady',
		'text'         : 'vender/require/text',

		'main'         : 'js/main',
		'router'       : 'js/router',
		'model'        : 'js/model/model',
		'view'         : 'js/view/view'

	},

	shim: {

		'backbone'     : {
			deps       : [ 'underscore', 'jquery' ],
			exports    : 'Backbone'
		},

		'underscore'   : {
			exports    : '_'
		},

		'jquery'       : {
			exports    : '$'
		},

		'handlebars'   : {
			exports    : 'Handlebars'
		}

	}

});
###

require.config {

	deps    : [ 'main' ]
	baseUrl : './'
	paths   :

		#vender
		'backbone'     : 'vender/backbone/backbone'
		'underscore'   : 'vender/underscore/underscore'
		'jquery'       : 'vender/jquery/jquery'
		'handlebars'   : 'vender/handlebars/handlebars'

		'domReady'     : 'vender/requirejs/domReady'
		'text'         : 'vender/requirejs/text'

		#mvc
		'main'         : 'js/demo/main'
		'router'       : 'js/demo/router'
		'model'        : 'js/demo/model/model'
		'view'         : 'js/demo/view/view'

		#core lib
		'MC'        : 'lib/MC.core'

		#service
		'service'   : 'service/session/session'
		'vo'        : 'service/session/session_vo'
		'parser'    : 'service/session/session_parser'

	shim   :

		'jquery'       :
			exports    : '$'

		'underscore'   :
			exports    : '_'

		'backbone'     :
			deps       : [ 'underscore', 'jquery' ]
			exports    : 'Backbone'

		'handlebars'   :
			exports    : 'Handlebars'

		'MC'        :
			deps    : [ 'jquery' ]
			exports : 'MC'
}