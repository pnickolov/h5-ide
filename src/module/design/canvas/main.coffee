####################################
#  Controller for design/canvas module
####################################

define [ 'event', 'MC', 'i18n!nls/lang.js' ], (ide_event, MC, lang ) ->

    #private
    loadModule = () ->

        #
        require [ './module/design/canvas/view',
                  './module/design/canvas/model'
        ], ( View, model ) ->

            #view
            view = new View()
            view.render()

            #listen OPEN_DESIGN
            # when 'NEW_STACK' result is tab_id
            # when Tabbar.current is 'appview' result is result
            ide_event.onLongListen ide_event.OPEN_DESIGN, ( region_name, type, current_platform, tab_name, result ) ->
                console.log 'canvas:OPEN_DESIGN', region_name, type, current_platform, tab_name, result

                try
                    #check re-render
                    view.reRender()
                    #
                    if type is 'NEW_STACK'

                        # create MC.canvas_data

                        #MC.canvas_data =
                        #    id       : result
                        #    name     : tab_name
                        #    region   : region_name
                        #    platform : current_platform

                        MC.forge.other.canvasData.set 'id'      , result
                        MC.forge.other.canvasData.set 'name'    , tab_name
                        MC.forge.other.canvasData.set 'region'  , region_name
                        MC.forge.other.canvasData.set 'platform', current_platform

                    else if type in [ 'OPEN_STACK', 'OPEN_APP' ]

                        #compact components
                        if type is 'OPEN_STACK'

                            # old design flow
                            #MC.canvas_data = MC.forge.stack.compactServerGroup MC.canvas_data

                            # new design flow
                            MC.forge.other.canvasData.save MC.forge.stack.compactServerGroup MC.forge.other.canvasData.data()

                        #### added by song, if the stack/app too old, unable to open ###
                        if MC.canvas_data.bad
                            notification 'error', lang.ide.IDE_MSG_ERR_OPEN_OLD_STACK_APP_TAB, true
                            ide_event.trigger ide_event.SWITCH_MAIN
                            ide_event.trigger ide_event.CLOSE_DESIGN_TAB, tab_name if tab_name
                            return
                        #### added by song, if the stack/app too old, unable to open ###

                        if Tabbar.current is 'appview'

                            # set MC.canvas_data

                            # old design flow
                            #MC.canvas_data = result.resolved_data[0]

                            # new design flow
                            MC.forge.other.canvasData.save result.resolved_data[0]

                            # set ami layout

                            # old design flow
                            #MC.aws.ami.setLayout MC.canvas_data

                            # new design flow
                            MC.aws.ami.setLayout MC.forge.other.canvasData.data()

                            # set analysis

                            # old design flow
                            #MC.canvas.analysis MC.canvas_data

                            # new design flow
                            MC.canvas.analysis MC.forge.other.canvasData.data()

                        # old design flow
                        #MC.aws.instance.updateStateIcon MC.canvas_data.id

                        # new design flow
                        MC.aws.instance.updateStateIcon MC.forge.other.canvasData.get( 'id' )

                    # new design flow +++++++++++++++++++++++++++
                    options =
                        type   : current_platform
                        mode   : Tabbar.current
                        region : region_name

                    if type is 'NEW_STACK'

                        # platform is classic
                        if options.type is Design.TYPE.Classic or options.type is Design.TYPE.DefaultVpc
                            component = $.extend true, {}, MC.canvas.DESIGN_INIT_DATA
                            layout    = MC.canvas.DESIGN_INIT_LAYOUT

                        # platform is vpc
                        else
                            component = $.extend true, {}, MC.canvas.DESIGN_INIT_DATA_VPC
                            layout    = MC.canvas.DESIGN_INIT_LAYOUT_VPC

                    else if type in [ 'OPEN_STACK', 'OPEN_APP' ]

                        # old design flow
                        #component = MC.canvas_data.component
                        #layout    = MC.canvas_data.layout

                        # new design flow
                        component  = MC.forge.other.canvasData.get( 'component' )
                        layout     = MC.forge.other.canvasData.get( 'layout' )

                    MC.canvas.layout.init()
                    new Design( component, layout, options )
                    # new design flow +++++++++++++++++++++++++++

                    # old design flow
                    #MC.data.origin_canvas_data = $.extend true, {}, MC.canvas_data

                    # new design flow
                    MC.forge.other.canvasData.origin MC.forge.other.canvasData.data()

                    MC.ta.list = []

                catch error
                    console.error error

                null

            #listen RESTORE_CANVAS
            ide_event.onLongListen ide_event.RESTORE_CANVAS, () ->
                console.log 'RESTORE_CANVAS'

                view.render()

                # old design flow +++++++++++++++++++++++++++
                #MC.canvas_data = $.extend( true, {}, MC.data.origin_canvas_data )
                #redraw
                #MC.canvas.layout.init()
                #re set
                #update instance icon of app
                #MC.aws.instance.updateStateIcon MC.canvas_data.id
                #MC.aws.asg.updateASGCount MC.canvas_data.id
                #MC.aws.eni.updateServerGroupState MC.canvas_data.id
                #update deleted resource style
                #MC.forge.app.updateDeletedResourceState MC.canvas_data
                # old design flow +++++++++++++++++++++++++++

                # new design flow +++++++++++++++++++++++++++

                # restore origin_canvas_data to MC.canvas_data
                MC.forge.other.canvasData.save MC.forge.other.canvasData.origin()

                # set options component layout
                options    =
                    type   : MC.forge.other.canvasData.get( 'platform'  )
                    mode   : Tabbar.current
                    region : MC.forge.other.canvasData.get( 'region'    )

                component  = MC.forge.other.canvasData.get( 'component' )
                layout     = MC.forge.other.canvasData.get( 'layout'    )

                # create Design
                MC.canvas.layout.init()
                new Design( component, layout, options )

                # new design flow +++++++++++++++++++++++++++

                # old design flow
                #MC.data.origin_canvas_data = $.extend( true, {}, MC.canvas_data )

                # new design flow
                MC.forge.other.canvasData.origin MC.forge.other.canvasData.data()

                null

            # ide_event.onLongListen ide_event.CREATE_LINE_TO_CANVAS, ( from_node, from_target_port, to_node, to_target_port, line_option ) ->
            #     MC.canvas.connect $("#" + from_node), from_target_port, $("#" + to_node), to_target_port, line_option

            # ide_event.onLongListen ide_event.DELETE_LINE_TO_CANVAS, ( line_id ) ->
            #     MC.canvas.remove $("#" + line_id)[0]

            # ide_event.onLongListen ide_event.NEED_IGW, ( component )->
            #     model.askToAddIGW()


            #listen CANVAS_ZOOMED_DROP_ERROR
            # view.on "CANVAS_ZOOMED_DROP_ERROR", ( event, option ) ->
            #     model.zoomedDropError event
            #     null

            #listen CANVAS_BEFORE_DROP
            # view.on "CANVAS_BEFORE_DROP", ( event, option ) ->
            #     model.beforeDrop event, option.src_node, option.tgt_parent
            #     null

            #listen CANVAS_BEFORE_ASG_EXPAND
            # view.on "CANVAS_BEFORE_ASG_EXPAND", ( event, option ) ->
            #     model.beforeASGExpand event, option.src_node, option.tgt_parent
            #     null

            #listen CANVAS_BEFORE_ASG_EXPAND
            # view.on "CHECK_CONNECTABLE_EVENT", ( event, option ) ->
            #     model.filterConnection event, option
            #     null




            #listen CANVAS_NODE_CHANGE_PARENT
            #listen CANVAS_GROUP_CHANGE_PARENT
            # view.on 'CANVAS_NODE_CHANGE_PARENT CANVAS_GROUP_CHANGE_PARENT', ( event, option ) ->
            #     model.changeParent event, option.src_node || option.src_group, option.tgt_parent
            #     null

            # #listen CANVAS_OBJECT_DELETE
            # view.on 'CANVAS_OBJECT_DELETE', ( event, option ) ->
            #     model.deleteObject event, option
            #     ide_event.trigger ide_event.CANVAS_DELETE_OBJECT
            #     null

            #listen CANVAS_LINE_CREATE
            # view.on 'CANVAS_LINE_CREATE', ( event, option ) ->
            #     model.createLine event, option
            #     ide_event.trigger ide_event.CANVAS_CREATE_LINE
            #     null

            #listen CANVAS_COMPONENT_CREATE
            # view.on 'CANVAS_COMPONENT_CREATE', ( event, option ) ->
            #     model.createComponent event, option
            #     null

            #listen CANVAS_EIP_STATE_CHANGE
            # view.on 'CANVAS_EIP_STATE_CHANGE', ( event, option ) ->
            #     model.setEip option.id, option.eip_state

            #     # update eip tooltip
            #     if (option.eip_state is 'on')
            #         MC.aws.eip.updateStackTooltip(option.id, true)
            #     else
            #         MC.aws.eip.updateStackTooltip(option.id, false)

            #     ide_event.trigger ide_event.PROPERTY_REFRESH_ENI_IP_LIST
            #     console.log 'EIP STATE CHANGED: instance: ' + option.id + ', eip_state:' + option.eip_state
            #     null

            #listen CANVAS_PLACE_NOT_MATCH
            # view.on 'CANVAS_PLACE_NOT_MATCH', (event, option) ->
            #     model.showNotMatchNotification option.type
            #     null

            #listen CANVAS_PLACE_OVERLAP
            # view.on 'CANVAS_PLACE_OVERLAP', (event) ->
            #     model.showOverlapNotification()
            #     null

            # view.on 'CANVAS_ASG_SELECTED', ( event, uid ) ->
            #     ide_event.trigger ide_event.OPEN_PROPERTY, 'component_asg_instance', uid

            # model.on 'SHOW_SG_LIST', ( line_id ) ->
            #     sgrule_main.loadModule line_id, 'delete'
            #     null

            # model.on 'CREATE_SG_CONNECTION', ( line_id ) ->
            #     sgrule_main.loadModule line_id
            #     null

            # #after delete object complete
            # model.on 'DELETE_OBJECT_COMPLETE', () ->

            #     #show property panel after remove resource
            #     ide_event.trigger ide_event.OPEN_PROPERTY, 'component', ''
            #     null

            # type : "node", "group", "line"
            # ide_event.onLongListen ide_event.DELETE_COMPONENT, ( component_id, type, not_force ) ->
            #     model.deleteObject null, {
            #         id    : component_id
            #         type  : type
            #         force : not not_force
            #     }

            # ide_event.onLongListen ide_event.CANVAS_UPDATE_APP_RESOURCE, () ->

            #     console.log 'CANVAS_UPDATE_APP_RESOURCE'
            #     #model.updateAppResource()

            #     null

            # null

    unLoadModule = () ->
        #view.remove()

    #public
    loadModule   : loadModule
    unLoadModule : unLoadModule
