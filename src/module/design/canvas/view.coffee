#############################
#  View(UI logic) for design/canvas
#############################

define [ 'event', 'canvas_layout', 'MC.canvas', 'backbone', 'jquery', 'handlebars', 'UI.notification' ], ( ide_event, canvas_layout ) ->

    CanvasView = Backbone.View.extend {

        el       : $( '#canvas' )

        initialize : ->
            #listen
            this.listenTo ide_event, 'SWITCH_TAB', ()->
                canvas_layout.listen()

            #bind event
            $( document )
                .on( 'CANVAS_NODE_SELECTED',        '#svg_canvas', this.showProperty )
                .on( 'CANVAS_ASG_VOLUME_SELECTED',  '#svg_canvas', this.showASGVolumeProperty )
                .on( 'CANVAS_LINE_SELECTED',        '#svg_canvas', this.lineSelected )
                .on( 'CANVAS_SAVE',                 '#svg_canvas', this, this.save )
                .on( 'CANVAS_NODE_CHANGE_PARENT CANVAS_GROUP_CHANGE_PARENT CANVAS_OBJECT_DELETE CANVAS_LINE_CREATE CANVAS_COMPONENT_CREATE CANVAS_EIP_STATE_CHANGE CANVAS_BEFORE_DROP CANVAS_PLACE_NOT_MATCH CANVAS_PLACE_OVERLAP CANVAS_ASG_SELECTED CANVAS_ZOOMED_DROP_ERROR CANVAS_BEFORE_ASG_EXPAND',   '#svg_canvas', _.bind( this.route, this ) )
                .on( 'DOMNodeInserted',             '.canvas-svg-group', this, _.debounce( this.canvasChange, 200, false ))

        render   : ( template ) ->
            console.log 'canvas render'
            $( '#canvas' ).html template
            #
            ide_event.trigger ide_event.DESIGN_SUB_COMPLETE

        reRender   : ( template ) ->
            console.log 're-canvas render'
            if $.trim( this.$el.html() ) is 'loading...' then $( '#canvas' ).html template

        showProperty : ( event, uid ) ->
            console.log 'showProperty, uid = ' + uid
            ide_event.trigger ide_event.OPEN_PROPERTY, 'component', uid

        showASGVolumeProperty : ( event, uid ) ->
            console.log 'showProperty, uid = ' + uid
            ide_event.trigger ide_event.OPEN_PROPERTY, 'component_asg_volume', uid

        lineSelected : ( event, line_id ) ->
            ide_event.trigger ide_event.OPEN_PROPERTY, 'line', line_id

        route : ( event, option ) ->
            # Dispatch the event to model
            this.trigger event.type, event, option

        save : () ->
            #save by ctrl+s
            ide_event.trigger ide_event.CANVAS_SAVE

        canvasChange : ( event ) ->
            console.log 'canvas:listen DOMNodeInserted'
            console.log MC.data.current_tab_type
            ide_event.trigger ide_event.SWITCH_WAITING_BAR if MC.data.current_tab_type is 'OLD_APP' or MC.data.current_tab_type is 'OLD_STACK'
            null
    }

    return CanvasView
