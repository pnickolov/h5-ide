#############################
#  View(UI logic) for design/canvas
#############################

define [ 'event', 'MC.canvas', 'backbone', 'jquery', 'handlebars' ], ( ide_event ) ->

    CanvasView = Backbone.View.extend {

        el       : $( '#canvas' )

        initialize : ->
            #listen
            this.listenTo ide_event, 'SWITCH_TAB', this.resizeCanvasPanel
            $( document ).delegate '#svg_canvas', 'CANVAS_NODE_SELECTED', this.showProperty

        render   : ( template ) ->
            console.log 'canvas render'
            this.$el.html template

        resizeCanvasPanel : ( type ) ->
            console.log 'resizeCanvasPanel = ' + type
            #temp resize canvas panel
            canvasPanelResize()
            #temp
            require [ 'canvas_layout' ], ( canvas_layout ) -> canvas_layout.listen()

        showProperty : ( event, uid ) ->
            console.log uid
            console.log event.target
            console.log event.currentTarget
            ide_event.trigger ide_event.OPEN_PROPERTY, uid

    }

    return CanvasView