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

        resizeCanvasPanel : ( type ) ->
            console.log 'resizeCanvasPanel = ' + type
            canvasPanelResize()
            if type is 'OLD_STACK' or type is 'OLD_APP'
                #temp
                require [ 'canvas-layout' ], ( canvas_layout ) ->
                    canvas_layout.connect()
                    canvas_layout.listen()
    }

    return CanvasView