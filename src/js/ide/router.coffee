
define [ 'backbone' ], ( Backbone ) ->

	AppRouter = Backbone.Router.extend {

		routes :
			#必须要放在最后
			'*actions': 'defaultRouter'

	}

	init = () ->
		router = new AppRouter()

		router.on 'route:defaultRouter', () ->

			require [ 'leftpanel' ], ( leftpanel ) ->

				#first load left panel
				leftpanel.loadModule()

				#second lod canvas
				require [ 'canvas' ], ( canvas ) ->
					canvas.loadModule()

		Backbone.history.start()

	initialize : init