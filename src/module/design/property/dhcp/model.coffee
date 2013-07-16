#############################
#  View Mode for design/property/dhcp
#############################

define [ 'backbone', 'jquery', 'underscore', 'MC' ], () ->

    DHCPModel = Backbone.Model.extend {

        defaults :
            'set_xxx'    : null
            'get_xxx'    : null

        initialize : ->
            #listen
            #this.listenTo this, 'change:get_host', this.getHost

    }

    model = new DHCPModel()

    return model