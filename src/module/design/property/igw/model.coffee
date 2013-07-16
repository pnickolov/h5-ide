#############################
#  View Mode for design/property/igw
#############################

define [ 'backbone', 'jquery', 'underscore', 'MC' ], () ->

    IGWModel = Backbone.Model.extend {

        defaults :
            'set_xxx'    : null
            'get_xxx'    : null

        initialize : ->
            #listen
            #this.listenTo this, 'change:get_host', this.getHost

    }

    model = new IGWModel()

    return model