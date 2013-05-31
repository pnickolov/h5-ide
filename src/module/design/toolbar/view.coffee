#############################
#  View(UI logic) for design/toolbar
#############################

define [ 'event', 'backbone', 'jquery', 'handlebars' ], ( event ) ->

    ToolbarView = Backbone.View.extend {

        el       : $( '#main-toolbar' )

        template : Handlebars.compile $( '#toolbar-tmpl' ).html()

        render   : () ->
            console.log 'toolbar render'
            $( this.el ).html this.template()
            #event.trigger event.DESIGN_COMPLETE
    }

    return ToolbarView