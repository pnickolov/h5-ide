#############################
#  View Mode for component/stateeditor
#############################

define [ 'backbone', 'jquery', 'underscore', 'MC' ], () ->

    StateEditorModel = Backbone.Model.extend {

        defaults :
            'set_xxx'    : null
            'get_xxx'    : null

        initialize : ->
            #listen
            #this.listenTo this, 'change:get_host', this.getHost

    }

    return StateEditorModel