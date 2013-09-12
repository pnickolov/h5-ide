define [ 'backbone', 'reg_main' ], ( Backbone, reg_main ) ->

	AppRouter = Backbone.Router.extend {
		routes :
			#
			'*actions'     : 'defaultRouter'

	}

	init = () ->
		router = new AppRouter()

		router.on 'route:defaultRouter', () ->
			reg_main.loadModule()

		Backbone.history.start()

	initialize : init