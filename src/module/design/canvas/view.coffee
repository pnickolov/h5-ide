#############################
#  View(UI logic) for design/canvas
#############################

define [ 'event', 'backbone', 'jquery', 'handlebars' ], ( event ) ->

    CanvasView = Backbone.View.extend {

        el       : $( '#canvas' )

        template : Handlebars.compile $( '#canvas-tmpl' ).html()

        render   : () ->
            console.log 'canvas render'
            $( this.el ).html this.template()
            #event.trigger event.DESIGN_COMPLETE
    }

    return CanvasView