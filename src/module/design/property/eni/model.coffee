#############################
#  View Mode for design/property/eni
#############################

define [ 'backbone', 'jquery', 'underscore', 'MC' ], () ->

    ENIModel = Backbone.Model.extend {

        defaults :
            'set_xxx'    : null
            'get_xxx'    : null

        initialize : ->
            #listen
            #this.listenTo this, 'change:get_host', this.getHost

    }

    model = new ENIModel()

    return model