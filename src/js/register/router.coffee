define [ 'backbone', 'register' ], ( Backbone, register ) ->

	AppRouter = Backbone.Router.extend {
		routes :
			'success'      : 'success'
			'*actions'     : 'defaultRouter'
	}

	init = () ->
		router = new AppRouter()

		router.on 'route:defaultRouter', () ->
			register.loadModule 'normal'

		router.on 'route:success', () ->
			register.loadModule 'success'

		Backbone.history.start()

	initialize : init