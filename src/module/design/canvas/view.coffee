#############################
#  View(UI logic) for design/canvas
#############################

define [ 'event', 'MC.canvas', 'backbone', 'jquery', 'handlebars' ], ( ide_event ) ->

    CanvasView = Backbone.View.extend {

        el       : $( '#canvas' )

        initialize : ->
            #listen
            this.listenTo ide_event, 'SWITCH_TAB', this.resizeCanvasPanel
            $( document ).delegate '#svg_canvas', 'CANVAS_NODE_SELECTED',     this.showProperty
            $( document ).delegate '#svg_canvas', 'CANVAS_NODE_CHANGE_GROUP', this.changeGroup

        render   : ( template ) ->
            console.log 'canvas render'
            $( '#canvas' ).html template
            #
            ide_event.trigger ide_event.DESIGN_SUB_COMPLETE

        reRender   : ( template ) ->
            console.log 're-canvas render'
            if $.trim( this.$el.html() ) is 'loading...' then $( '#canvas' ).html template

        resizeCanvasPanel : ( type ) ->
            console.log 'resizeCanvasPanel = ' + type
            #temp resize canvas panel
            canvasPanelResize()
            #temp
            require [ 'canvas_layout' ], ( canvas_layout ) -> canvas_layout.listen()

        showProperty : ( event, uid ) ->
            console.log 'showProperty, uid = ' + uid
            ide_event.trigger ide_event.OPEN_PROPERTY, uid

        changeGroup : ( event, src_node, tgt_group ) ->
            console.log 'changeGroup, src_node = ' + src_node + ', tgt_group = ' + tgt_group

    }

    return CanvasView