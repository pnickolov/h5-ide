#############################
#  View(UI logic) for design/canvas
#############################

define [ 'event', 'MC.canvas', 'backbone', 'jquery', 'handlebars' ], ( ide_event ) ->

    CanvasView = Backbone.View.extend {

        el       : $( '#canvas' )

        initialize : ->
            #listen
            this.listenTo ide_event, 'SWITCH_TAB', this.resizeCanvasPanel

            #bind event
            $( document )
                .on( 'CANVAS_NODE_SELECTED',        '#svg_canvas', this.showProperty )
                .on( 'CANVAS_NODE_CHANGE_PARENT',   '#svg_canvas', this, this.changeNodeParent )
                .on( 'CANVAS_GROUP_CHANGE_PARENT',  '#svg_canvas', this, this.changeGroupParent )
                .on( 'CANVAS_LINE_SELECTED',        '#svg_canvas', this.lineSelected )
                .on( 'CANVAS_OBJECT_DELETE',        '#svg_canvas', this, this.deleteObject )
                .on( 'CANVAS_LINE_CREATE',          '#svg_canvas', this, this.createLine )

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
            ide_event.trigger ide_event.OPEN_PROPERTY, 'component', uid

        lineSelected : ( event, line_id ) ->
            ide_event.trigger ide_event.OPEN_PROPERTY, 'line', uid



        changeNodeParent : ( event, option ) ->
            event.data.trigger ide_event.CANVAS_NODE_CHANGE_PARENT, option.src_node, option.tgt_parent

        changeGroupParent : ( event, option ) ->
            event.data.trigger ide_event.CANVAS_GROUP_CHANGE_PARENT, option.src_group, option.tgt_parent

        deleteObject : ( event, option ) ->
            event.data.trigger ide_event.CANVAS_OBJECT_DELETE, option

        createLine : ( event, line_id ) ->
            event.data.trigger ide_event.CANVAS_LINE_CREATE, line_id


    }

    return CanvasView