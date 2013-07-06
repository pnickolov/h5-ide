#############################
#  View Mode for design/property/instance
#############################

define [ 'backbone', 'jquery', 'underscore' ], () ->

    InstanceModel = Backbone.Model.extend {

        defaults :
            'head'    : 'Instance Details'

    }

    model = new InstanceModel()

    return model