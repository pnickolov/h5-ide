#############################
#  View Mode for design/property/vgw
#############################

define [ 'backbone', 'jquery', 'underscore', 'MC' ], () ->

    VGWModel = Backbone.Model.extend {

        defaults :
            'set_xxx'    : null
            'get_xxx'    : null

        initialize : ->
            #listen
            #this.listenTo this, 'change:get_host', this.getHost

    }

    model = new VGWModel()

    return model