#############################
#  router for ide
#############################

define [ 'backbone' ], ( Backbone ) ->

	AppRouter = Backbone.Router.extend {

		routes :
			#必须要放在最后
			'*actions': 'defaultRouter'

	}

	init = () ->
		router = new AppRouter()

		router.on 'route:defaultRouter', () ->

			require [ 'ide' ], ( ide ) ->
				ide.initialize()

		Backbone.history.start()

	initialize : init