#############################
#  View Mode for component/tutorial
#############################

define [ 'backbone', 'jquery', 'underscore', 'MC' ], () ->

    TutorialModel = Backbone.Model.extend {

        defaults :
            'set_xxx'    : null
            'get_xxx'    : null

        initialize : ->
            #listen
            #this.listenTo this, 'change:get_host', this.getHost

    }

    return TutorialModel