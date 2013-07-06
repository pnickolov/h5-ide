#############################
#  View Mode for design/property/advanced_details
#############################

define [ 'backbone', 'jquery', 'underscore' ], () ->

    AdvancedDetailsModel = Backbone.Model.extend {

        defaults :
            'head'    : 'Advanced Details'

    }

    model = new AdvancedDetailsModel()

    return model