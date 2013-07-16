#############################
#  View Mode for design/property/cgw
#############################

define [ 'backbone', 'jquery', 'underscore', 'MC' ], () ->

    CGWModel = Backbone.Model.extend {

        defaults :
            'set_xxx'    : null
            'get_xxx'    : null

        initialize : ->
            #listen
            #this.listenTo this, 'change:get_host', this.getHost

    }

    model = new CGWModel()

    return model