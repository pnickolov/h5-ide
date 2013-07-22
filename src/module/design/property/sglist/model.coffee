#############################
#  View Mode for design/property/sglist
#############################

define [ 'backbone', 'jquery', 'underscore' ], () ->

    SGListModel = Backbone.Model.extend {

        defaults :
            'get_xxx'    : null

        #initialize : ->
        #    #listen
        #    #this.listenTo this, 'change:get_host', this.getHost

    }

    model = new SGListModel()

    return model