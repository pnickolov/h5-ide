#############################
#  View Mode for design/property/instance
#############################

define [ 'backbone', 'jquery', 'underscore', 'MC' ], () ->

    InstanceModel = Backbone.Model.extend {

        defaults :
            'set_xxx'    : null
            'get_xxx'    : null

        initialize : ->
            #listen
            #this.listenTo this, 'change:get_host', this.getHost

    }

    model = new InstanceModel()

    return model