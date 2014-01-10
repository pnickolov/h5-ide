#############################
#  View Mode for component/trustedadvisor
#############################

define [ 'backbone', 'jquery', 'underscore', 'MC' ], () ->

    StateStatusModel = Backbone.Model.extend {

        defaults :
            test: null
    }

    return StateStatusModel