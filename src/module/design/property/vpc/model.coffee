#############################
#  View Mode for design/property/vpc
#############################

define [ 'backbone', 'jquery', 'underscore', 'MC' ], () ->

    VPCModel = Backbone.Model.extend {

        defaults :
            'set_xxx'    : null
            'get_xxx'    : null

        initialize : ->
            #listen
            #this.listenTo this, 'change:get_host', this.getHost

    }

    model = new VPCModel()

    return model
