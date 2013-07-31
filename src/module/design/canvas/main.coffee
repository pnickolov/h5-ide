####################################
#  Controller for design/canvas module
####################################

define [ 'jquery', 'text!/module/design/canvas/template.html', 'event', 'MC' ], ( $, template, ide_event, MC ) ->

    #private
    loadModule = () ->

        #load remote module1.js
        require [ './module/design/canvas/view', './module/design/canvas/model', './component/sgrule/main' ], ( View, model, sgrule_main ) ->

            #view
            view       = new View()
            view.render template

            #listen RELOAD_RESOURCE
            ide_event.onLongListen ide_event.RELOAD_RESOURCE, ( region_name, type, current_platform, tab_name, tab_id ) ->
                console.log 'canvas:RELOAD_RESOURCE, region_name = ' + region_name + ', type = ' + type + ', current_platform = ' + current_platform + ', tab_name = ' + tab_name + ', tab_id = ' + tab_id
                #check re-render
                view.reRender template
                #temp
                if type is 'NEW_STACK'
                    require [ 'canvas_layout' ], ( canvas_layout ) -> MC.canvas.layout.create {
                                id       : tab_id
                                name     : tab_name,
                                region   : region_name,
                                platform : current_platform
                            }
                else if type is 'OPEN_STACK' or type is 'OPEN_APP'
                    require [ 'canvas_layout' ], ( canvas_layout ) -> MC.canvas.layout.init()
                null


            ide_event.onLongListen ide_event.CREATE_LINE_TO_CANVAS, ( from_node, from_target_port, to_node, to_target_port, line_option ) ->

                MC.canvas.connect $("#" + from_node), from_target_port, $("#" + to_node), to_target_port, line_option

            ide_event.onLongListen ide_event.DELETE_LINE_TO_CANVAS, ( line_id ) ->

                MC.canvas.remove $("#" + line_id)[0]

            ide_event.onLongListen ide_event.REDRAW_SG_LINE, () ->

                model.reDrawSgLine()

            #listen CANVAS_NODE_CHANGE_PARENT
            view.on 'CANVAS_NODE_CHANGE_PARENT', ( src_node, tgt_parent ) ->
                console.log 'canvas:CANVAS_NODE_CHANGE_PARENT, src_node = ' + src_node + ', tgt_parent = ' + tgt_parent
                model.changeNodeParent src_node, tgt_parent
                null

            #listen CANVAS_GROUP_CHANGE_PARENT
            view.on 'CANVAS_GROUP_CHANGE_PARENT', ( src_group, tgt_parent ) ->
                console.log 'canvas:CANVAS_GROUP_CHANGE_PARENT, src_group = ' + src_group + ', tgt_parent = ' + tgt_parent
                model.changeGroupParent src_group, tgt_parent
                null

            #listen CANVAS_OBJECT_DELETE
            view.on 'CANVAS_OBJECT_DELETE', ( option ) ->
                console.log 'canvas:CANVAS_OBJECT_DELETE, option = ' + option
                # remove line
                model.deleteObject option
                ide_event.trigger ide_event.CANVAS_DELETE_OBJECT
                null

            #listen CANVAS_LINE_CREATE
            view.on 'CANVAS_LINE_CREATE', ( line_id ) ->
                console.log 'canvas:CANVAS_LINE_CREATE, line_id = ' + line_id
                model.createLine line_id
                ide_event.trigger ide_event.CANVAS_CREATE_LINE
                null

            #listen CANVAS_COMPONENT_CREATE
            view.on 'CANVAS_COMPONENT_CREATE', ( uid ) ->
                console.log 'canvas:CANVAS_COMPONENT_CREATE, uid = ' + uid
                model.createComponent uid

                ide_event.trigger ide_event.UPDATE_COST_ESTIMATE

                null

            #listen CANVAS_EIP_STATE_CHANGE
            view.on 'CANVAS_EIP_STATE_CHANGE', (uid, eip_state) ->

                model.setEip uid, eip_state
                console.log 'EIP STATE CHANGED: instance: ' + uid + ', eip_state:' + eip_state

            model.on 'SHOW_SG_LIST', ( line_id ) ->

                sgrule_main.loadModule line_id, 'delete'

            model.on 'ENI_REACH_MAX', ()->
                console.log 'ENI reach limit'
                view.showEniReachMax()

            model.on 'CREATE_SG_CONNECTION', ( line_id ) ->

                sgrule_main.loadModule line_id

            null

    unLoadModule = () ->
        #view.remove()

    #public
    loadModule   : loadModule
    unLoadModule : unLoadModule
