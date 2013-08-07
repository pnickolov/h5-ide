#############################
#  View Mode for design/property/instance
#############################

define [ 'constant', 'event', 'backbone', 'jquery', 'underscore', 'MC' ], (constant, ide_event) ->

	LaunchConfigModel = Backbone.Model.extend {

		defaults :
			uid : null

		initialize : ->
			null
	}

	model = new LaunchConfigModel()

	return model
