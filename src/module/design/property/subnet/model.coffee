#############################
#  View Mode for design/property/subnet
#############################

define [ 'backbone', 'jquery', 'underscore', 'MC' ], () ->

    SubnetModel = Backbone.Model.extend {

        defaults :
            'set_xxx'    : null
            'get_xxx'    : null

        initialize : ->
            #listen
            #this.listenTo this, 'change:get_host', this.getHost

    }

    model = new SubnetModel()

    return model