#############################
#  View(UI logic) for design/canvas
#############################

define [ './template', "event", "constant", "canvas_layout", 'MC.canvas', 'backbone', 'jquery' ], ( template, ide_event, constant, canvas_layout ) ->

    CanvasView = Backbone.View.extend {

        initialize : ->
            this.template = template()

            #listen
            this.listenTo ide_event, 'SWITCH_TAB', ()->
                canvas_layout.listen()

            this.listenTo ide_event, 'UPDATE_RESOURCE_STATE', ()->
                canvas_layout.listen()


        render : () ->

            console.log 'canvas render'
            $( '#canvas' ).html this.template
            ide_event.trigger ide_event.DESIGN_SUB_COMPLETE

        reRender   : ( template ) ->

            console.log 're-canvas render'
            if $("#canvas").is(":empty") then $( '#canvas' ).html this.template

            null
    }

    return CanvasView
