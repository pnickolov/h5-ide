#############################
#  View Mode for design/property/az
#############################

define [ 'backbone', 'jquery', 'underscore', 'MC' ], () ->

    AZModel = Backbone.Model.extend {

        defaults :
            'set_xxx'    : null
            'get_xxx'    : null

        initialize : ->
            #listen
            #this.listenTo this, 'change:get_host', this.getHost

    }

    model = new AZModel()

    return model