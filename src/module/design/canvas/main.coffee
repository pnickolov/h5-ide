####################################
#  Controller for design/canvas module
####################################

define [ 'jquery', 'text!/module/design/canvas/template.html', 'event' ], ( $, template, ide_event ) ->

    #private
    loadModule = () ->

        #load remote module1.js
        require [ './module/design/canvas/view', './module/design/canvas/model' ], ( View, model ) ->

            #view
            view       = new View()
            view.render template

            #listen RELOAD_RESOURCE
            ide_event.onLongListen ide_event.RELOAD_RESOURCE, ( region_name, type, current_platform, tab_name ) ->
                console.log 'canvas:RELOAD_RESOURCE, region_name = ' + region_name + ', type = ' + type + ', current_platform = ' + current_platform + ', tab_name = ' + tab_name
                #check re-render
                view.reRender template
                #temp
                if type is 'NEW_STACK'
                    require [ 'canvas_layout' ], ( canvas_layout ) -> MC.canvas.layout.create({
                                name: tab_name,
                                region: region_name,
                                platform: current_platform
                            })
                else if type is 'OPEN_STACK'
                    require [ 'canvas_layout' ], ( canvas_layout ) -> MC.canvas.layout.init()
                null


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
                model.deleteObject option
                null

            #listen CANVAS_LINE_CREATE
            view.on 'CANVAS_LINE_CREATE', ( line_id ) ->
                console.log 'canvas:CANVAS_LINE_CREATE, line_id = ' + line_id
                model.createLine line_id
                null

            #listen CANVAS_COMPONENT_CREATE
            view.on 'CANVAS_COMPONENT_CREATE', ( uid ) ->
                console.log 'canvas:CANVAS_COMPONENT_CREATE, uid = ' + uid
                model.createComponent uid
                null



            null

    unLoadModule = () ->
        #view.remove()

    #public
    loadModule   : loadModule
    unLoadModule : unLoadModule
