
define [ 'backbone' ], ( Backbone ) ->

	AppRouter = Backbone.Router.extend {

		routes :
			#必须要放在最后
			'*actions': 'defaultRouter'

	}

	init = () ->
		router = new AppRouter()

		router.on 'route:defaultRouter', () ->

			require [ 'leftpanel' ], ( LeftPanel ) ->

				#first load left panel
				LeftPanel.loadModule()

				#second lod canvas
				require [ 'canvas' ], ( CanvasPanel ) ->
					CanvasPanel.loadModule()

		Backbone.history.start()

	initialize : init