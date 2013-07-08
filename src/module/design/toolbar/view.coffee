#############################
#  View(UI logic) for design/toolbar
#############################

define [ 'event',
         'backbone', 'jquery', 'handlebars'
         'UI.selectbox'
], ( event ) ->

    ToolbarView = Backbone.View.extend {

        el       : $ '#main-toolbar'

        render   : ( template ) ->
            console.log 'toolbar render'
            $( '#main-toolbar' ).html template
    }

    return ToolbarView