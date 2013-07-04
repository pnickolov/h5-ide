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
                require [ 'canvas_layout' ], ( canvas_layout ) ->
                    canvas_layout.listen()

            if type is 'NEW_STACK'
                require [ 'canvas_layout' ], ( canvas_layout ) ->
                    MC.canvas.layout.create()
                    canvas_layout.listen()

            if type is 'OPEN_STACK'
                #temp
                require [ 'canvas_layout' ], ( canvas_layout ) ->
                    #MC.canvas.layout.init()
                    canvas_layout.listen()
                    canvas_layout.ready()
                    # canvas_layout.connect()
    }

    return CanvasView