
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
				
				require [ 'canvas' ], ( CanvasPanel ) ->
					#second lod canvas
					CanvasPanel.loadModule()

					true

			true

		Backbone.history.start()

	initialize : init