define [ 'backbone', 'reset_main' ], ( Backbone, reset_main ) ->

	AppRouter = Backbone.Router.extend {
		routes :
			'email'         : 'email'
			'password/:key' : 'password'
			'expire'        : 'expire'
			'success'       : 'success'
			'*actions'      : 'defaultRouter'
	}

	init = () ->
		router = new AppRouter()

		router.on 'route:defaultRouter', () ->
			reset_main.loadModule 'normal'

		router.on 'route:email', () ->
			reset_main.loadModule 'email'

		router.on 'route:password', ( key ) ->
			reset_main.loadModule 'password', key

		router.on 'route:expire', () ->
			reset_main.loadModule 'expire'

		router.on 'route:success', () ->
			reset_main.loadModule 'success'

		Backbone.history.start()

	initialize : init