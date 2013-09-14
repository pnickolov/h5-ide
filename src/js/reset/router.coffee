define [ 'backbone', 'reset_main' ], ( Backbone, reset_main ) ->

	AppRouter = Backbone.Router.extend {
		routes :
			'password'     : 'password'
			'email'        : 'email'
			'success'      : 'success'
			'*actions'     : 'defaultRouter'

	}

	init = () ->
		router = new AppRouter()

		router.on 'route:defaultRouter', () ->
			reset_main.loadModule 'normal'

		router.on 'route:password', () ->
			reset_main.loadModule 'password'

		router.on 'route:email', () ->
			reset_main.loadModule 'email'

		router.on 'route:success', () ->
			reset_main.loadModule 'success'

		Backbone.history.start()

	initialize : init