#############################
#  View(UI logic) for design/canvas
#############################

define [ 'event', 'canvas_layout', 'constant',
         'lib/forge/app',
         'stateeditor'
         'MC.canvas', 'backbone', 'jquery'
], ( ide_event, canvas_layout, constant, forge_app, stateeditor ) ->

    CanvasView = Backbone.View.extend {

        el       : $( '#canvas' )

        initialize : ->
            #listen
            this.listenTo ide_event, 'SWITCH_TAB', ()->
                canvas_layout.listen()

            this.listenTo ide_event, 'UPDATE_RESOURCE_STATE', ()->
                canvas_layout.listen()

                app_id = MC.canvas_data.id

                #update resource state
                MC.aws.instance.updateStateIcon app_id
                MC.aws.asg.updateASGCount app_id
                MC.aws.eni.updateServerGroupState app_id
                MC.forge.app.updateDeletedResourceState MC.canvas_data

                null

            #bind event
            $( document )
                .on( 'CANVAS_NODE_SELECTED',        '#svg_canvas', this.showProperty )
                .on( 'CANVAS_ASG_VOLUME_SELECTED',  '#svg_canvas', this.showASGVolumeProperty )
                .on( 'CANVAS_INSTANCE_SELECTED',    '#svg_canvas', this.showInstanceProperty )
                .on( 'CANVAS_ENI_SELECTED',         '#svg_canvas', this.showEniProperty )
                .on( 'CANVAS_LINE_SELECTED',        '#svg_canvas', this.lineSelected )
                .on( 'CANVAS_SAVE',                 '#svg_canvas', this, this.save )
                .on( 'SHOW_PROPERTY_PANEL',         '#svg_canvas', this, @showPropertyPanel )
                .on( 'CANVAS_NODE_CHANGE_PARENT CANVAS_GROUP_CHANGE_PARENT CANVAS_OBJECT_DELETE CANVAS_LINE_CREATE CANVAS_COMPONENT_CREATE CANVAS_EIP_STATE_CHANGE CANVAS_BEFORE_DROP CANVAS_PLACE_NOT_MATCH CANVAS_PLACE_OVERLAP CANVAS_ASG_SELECTED CANVAS_ZOOMED_DROP_ERROR CANVAS_BEFORE_ASG_EXPAND CHECK_CONNECTABLE_EVENT ',   '#svg_canvas', _.bind( this.route, this ) )
                .on( 'STATE_ICON_CLICKED',          '#svg_canvas', this.openStateEditor )

        render   : ( template ) ->
            console.log 'canvas render'
            $( '#canvas' ).html template
            #
            ide_event.trigger ide_event.DESIGN_SUB_COMPLETE

        reRender   : ( template ) ->
            console.log 're-canvas render'
            if $.trim( this.$el.html() ) is 'loading...' then $( '#canvas' ).html template

        showInstanceProperty : ( event, uid ) ->
            # Directly open the instance property
            ide_event.trigger ide_event.OPEN_PROPERTY, 'component', uid
            null

        showEniProperty : ( event, uid ) ->
            ide_event.trigger ide_event.OPEN_PROPERTY, 'component', uid
            null

        showProperty : ( event, uid ) ->
            console.log 'showProperty, uid = ' + uid
            # In App / AppEdit mode, when clicking Instance. Switch to ServerGroup
            type  = "component"
            state = MC.canvas.getState()

            component = MC.canvas_data.component[uid]
            if component
                if component.type is constant.AWS_RESOURCE_TYPE.AWS_EC2_Instance or component.type is constant.AWS_RESOURCE_TYPE.AWS_VPC_NetworkInterface
                    # In AppEdit, newly created instance/eni will make forge_app.existing_app_resource return false.
                    # In app mode, component's number that is not 1 is servergroup.
                    if ( state is "appedit" and forge_app.existing_app_resource( uid ) is true ) or (state is "app" and  "" + component.number isnt "1")
                        if component.type is constant.AWS_RESOURCE_TYPE.AWS_EC2_Instance
                            type = "component_server_group"
                        else
                            type = "component_eni_group"
            else
                layout_data = MC.canvas_data.layout.component.group[uid]
                if layout_data and layout_data.type is constant.AWS_RESOURCE_TYPE.AWS_AutoScaling_Group and layout_data.originalId
                        uid = layout_data.originalId

            ide_event.trigger ide_event.OPEN_PROPERTY, type, uid

            null

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

        showPropertyPanel : ->
            console.log 'showPropertyPanel'
            ide_event.trigger ide_event.SHOW_PROPERTY_PANEL
            null

        openStateEditor : ( event, uid ) ->

            compObj = MC.canvas_data.component[uid]
            compType = compObj.type
            if compObj and compType in [constant.AWS_RESOURCE_TYPE.AWS_EC2_Instance, constant.AWS_RESOURCE_TYPE.AWS_AutoScaling_LaunchConfiguration]
                stateeditor.loadModule(MC.canvas_data, uid)
            null

    }

    return CanvasView
