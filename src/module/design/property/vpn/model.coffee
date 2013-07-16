#############################
#  View Mode for design/property/vpn
#############################

define [ 'backbone', 'jquery', 'underscore', 'MC' ], () ->

    VPNModel = Backbone.Model.extend {

        defaults :
            'set_xxx'    : null
            'get_xxx'    : null

        initialize : ->
            #listen
            #this.listenTo this, 'change:get_host', this.getHost

    }

    model = new VPNModel()

    return model