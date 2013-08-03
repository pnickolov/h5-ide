#############################
#  View(UI logic) for design/canvas
#############################

define [ 'event', 'MC.canvas', 'backbone', 'jquery', 'handlebars', 'UI.notification' ], ( ide_event ) ->

    CanvasView = Backbone.View.extend {

        el       : $( '#canvas' )

        initialize : ->
            #listen
            this.listenTo ide_event, 'SWITCH_TAB', this.resizeCanvasPanel

            #bind event
            $( document )
                .on( 'CANVAS_NODE_SELECTED',        '#svg_canvas', this.showProperty )
                .on( 'CANVAS_LINE_SELECTED',        '#svg_canvas', this.lineSelected )
                .on( 'CANVAS_SAVE',                 '#svg_canvas', this, this.save )

                .on( 'CANVAS_NODE_CHANGE_PARENT CANVAS_GROUP_CHANGE_PARENT CANVAS_OBJECT_DELETE CANVAS_LINE_CREATE CANVAS_COMPONENT_CREATE CANVAS_EIP_STATE_CHANGE CANVAS_BEFORE_DROP',   '#svg_canvas', _.bind( this.route, this ) )

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
            #canvasPanelResize()
            canvas_resize()
            #temp
            require [ 'canvas_layout' ], ( canvas_layout ) -> canvas_layout.listen()

        showProperty : ( event, uid ) ->
            console.log 'showProperty, uid = ' + uid
            ide_event.trigger ide_event.OPEN_PROPERTY, 'component', uid

            # added by song, temp
            if jsonView then jsonView(uid)

        lineSelected : ( event, line_id ) ->
            ide_event.trigger ide_event.OPEN_PROPERTY, 'line', line_id

        route : ( event, option ) ->
            # Dispatch the event to model
            this.trigger event.type, event, option

        showEniReachMax : () ->
            notification 'info', 'The Instance you selected has attach too many eni, please unattach one or change the instance type.'

        save : () ->
            #save by ctrl+s
            ide_event.trigger ide_event.CANVAS_SAVE
    }

    return CanvasView
