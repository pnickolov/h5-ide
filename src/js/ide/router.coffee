
define [ 'backbone' ], ( Backbone ) ->

	AppRouter = Backbone.Router.extend {

		routes :
			#必须要放在最后
			'*actions': 'defaultRouter'

	}

	init = () ->
		router = new AppRouter()

		router.on 'route:defaultRouter', () ->

			require [ 'leftpanel' ], ( left_panel ) ->

				#first load left panel
				left_panel.loadModule()
				
				require [ 'canvas' ], ( canvas_panel ) ->
					#second lod canvas
					canvas_panel.loadModule()

					true

			true

		Backbone.history.start()

	initialize : init