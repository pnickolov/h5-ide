
require.config {

	baseUrl            : './'

	deps               : [ 'js/ide/main' ]

	paths              :

		#vender
		'jquery'       : 'vender/jquery/jquery'
		'canvon'       : 'vender/canvon/canvon'

		'underscore'   : 'vender/underscore/underscore'
		'backbone'     : 'vender/backbone/backbone'
		'handlebars'   : 'vender/handlebars/handlebars'

		'domReady'     : 'vender/requirejs/domReady'
		'text'         : 'vender/requirejs/text'

		#cor lib
		'MC'           : 'lib/MC.core'
		'MC.topo'      : 'lib/MC.topo'
		'MC.canvas'    : 'lib/MC.canvas'

		#ui
		'UI.tooltip'   : 'ui/common/UI.tooltip'
		'UI.scrollbar' : 'ui/common/UI.scrollbar'

		#ide(leftpanel canvas)
		'router'       : 'js/ide/router'
		'leftpanel'    : 'module/leftpanel/main'
		'canvas'       : 'module/canvas/main'

	shim               :

		'jquery'       :
			exports    : '$'
		
		'canvon'       :
			deps       : [ 'jquery' ]
			exports    : 'Canvon'

		'underscore'   :
			exports    : '_'

		'backbone'     :
			deps       : [ 'underscore', 'jquery' ]
			exports    : 'Backbone'

		'handlebars'   :
			exports    : 'Handlebars'
		
		'MC'           :
			deps       : [ 'jquery' ]
			exports    : 'MC'
		
		'MC.topo'      :
			deps       : [ 'MC' ]
			exports    : 'MC.topo'
		
		'MC.canvas'    :
			deps       : [ 'MC', 'MC.topo' ]
			exports    : 'MC.canvas'
		
		'UI.tooltip'     :
			deps       : [ 'MC' ]
			exports    : 'MC.tooltip'
		
		'UI.scrollbar'     :
			deps       : [ 'MC' ]
			exports    : 'scrollbar'
}