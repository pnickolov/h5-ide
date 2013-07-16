#############################
#  View Mode for design/property/rtb
#############################

define [ 'backbone', 'jquery', 'underscore', 'MC' ], () ->

    RTBModel = Backbone.Model.extend {

        defaults :
            'set_xxx'    : null
            'get_xxx'    : null

        initialize : ->
            #listen
            #this.listenTo this, 'change:get_host', this.getHost

    }

    model = new RTBModel()

    return model