define [ 'backbone', 'reset_main' ], ( Backbone, reset_main ) ->

	AppRouter = Backbone.Router.extend {
		routes :
			'password'     : 'password'
			'success'      : 'success'
			'*actions'     : 'defaultRouter'

	}

	init = () ->
		router = new AppRouter()

		router.on 'route:defaultRouter', () ->
			reset_main.loadModule 'normal'

		router.on 'route:success', () ->
			reset_main.loadModule 'success'

		router.on 'route:password', () ->
			reset_main.loadModule 'password'

		Backbone.history.start()

	initialize : init