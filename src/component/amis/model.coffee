#############################
#  View Mode for component/amis
#############################

define [ 'backbone', 'jquery', 'underscore', 'MC' ], () ->

    AMIsModel = Backbone.Model.extend {

        defaults :
            'set_xxx'    : null
            'get_xxx'    : null

        initialize : ->
            #listen
            #this.listenTo this, 'change:get_host', this.getHost

    }

    return AMIsModel