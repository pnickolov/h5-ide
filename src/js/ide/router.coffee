#############################
#  router for ide
#############################

define [ 'backbone', 'ide' ], ( Backbone, ide ) ->

	AppRouter = Backbone.Router.extend {

		routes :
			#必须要放在最后
			'*actions': 'defaultRouter'

	}

	init = () ->
		router = new AppRouter()

		router.on 'route:defaultRouter', () ->
			ide.initialize()

		Backbone.history.start()

	initialize : init