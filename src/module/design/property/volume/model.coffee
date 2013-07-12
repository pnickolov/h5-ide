#############################
#  View Mode for design/property/volume
#############################

define [ 'backbone', 'jquery', 'underscore', 'MC' ], () ->

    VolumeModel = Backbone.Model.extend {

        defaults :
            'set_xxx'    : null
            'get_xxx'    : null

        initialize : ->
            #listen
            #this.listenTo this, 'change:get_host', this.getHost

    }

    model = new VolumeModel()

    return model