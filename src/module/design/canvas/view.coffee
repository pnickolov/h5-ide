#############################
#  View(UI logic) for design/canvas
#############################

define [ 'event', 'MC.canvas', 'backbone', 'jquery', 'handlebars' ], ( ide_event ) ->

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
            canvasPanelResize()

    }

    return CanvasView