define [ 'backbone', 'reg_main' ], ( Backbone, reg_main ) ->

	AppRouter = Backbone.Router.extend {
		routes :
			'success'      : 'success'
			'*actions'     : 'defaultRouter'
	}

	init = () ->
		router = new AppRouter()

		router.on 'route:defaultRouter', () ->
			reg_main.loadModule 'normal'

		router.on 'route:success', () ->
			reg_main.loadModule 'success'

		Backbone.history.start()

	initialize : init