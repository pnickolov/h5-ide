#############################
#  View Mode for header module
#############################

define [ 'event', 'backbone', 'jquery', 'underscore' ], ( ide_event ) ->

    ProcessModel = Backbone.Model.extend {

        defaults:
        	'xxxx' : null

    }

    model = new ProcessModel()
    return model
