#############################
#  View(UI logic) for design/toolbar
#############################

define [ 'event', 'backbone', 'jquery', 'handlebars' ], ( event ) ->

    ToolbarView = Backbone.View.extend {

        el       : $ '#main-toolbar'

        render   : ( template ) ->
            console.log 'toolbar render'
            $( this.el ).html template
    }

    return ToolbarView