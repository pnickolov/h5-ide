#############################
#  View(UI logic) for design/canvas
#############################

define [ 'event', 'canvas-layout', 'MC.canvas', 'backbone', 'jquery', 'handlebars' ], ( ide_event, canvas_layout ) ->

    CanvasView = Backbone.View.extend {

        el       : $( '#canvas' )

        initialize : ->
            #listen
            this.listenTo ide_event, 'SWITCH_TAB', this.resizeCanvasPanel

        render   : ( template ) ->
            console.log 'canvas render'
            this.$el.html template

        resizeCanvasPanel : (event) ->
            console.log 'resizeCanvasPanel'
            canvas_layout.ready()
            canvasPanelResize()

    }

    return CanvasView