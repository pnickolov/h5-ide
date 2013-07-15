#############################
#  View Mode for design/property/elb
#############################

define [ 'backbone', 'jquery', 'underscore', 'MC' ], () ->

    ELBModel = Backbone.Model.extend {

        defaults :
            'set_xxx'    : null
            'get_xxx'    : null

        initialize : ->
            #listen
            #this.listenTo this, 'change:get_host', this.getHost

    }

    model = new ELBModel()

    return model