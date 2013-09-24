define [ 'backbone', 'reset' ], ( Backbone, reset ) ->

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
			reset.loadModule 'normal'

		router.on 'route:email', () ->
			reset.loadModule 'email'

		router.on 'route:password', ( key ) ->
			reset.loadModule 'password', key

		router.on 'route:expire', () ->
			reset.loadModule 'expire'

		router.on 'route:success', () ->
			reset.loadModule 'success'

		Backbone.history.start()

	initialize : init