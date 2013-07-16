####################################
#  Controller for design/canvas module
####################################

define [ 'jquery', 'text!/module/design/canvas/template.html', 'event', 'module/design/canvas/canvas' ], ( $, template, ide_event, canvas ) ->

    #private
    loadModule = () ->

        #load remote module1.js
        require [ './module/design/canvas/view' ], ( View ) ->

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


            #listen CANVAS_NODE_CHANGE_GROUP
            ide_event.onLongListen ide_event.CANVAS_NODE_CHANGE_GROUP, ( src_node, tgt_group ) ->
                console.log 'canvas:CANVAS_NODE_CHANGE_GROUP, src_node = ' + src_node + ', tgt_group = ' + tgt_group
                canvas.nodeChangeGroup src_node, tgt_group
                null

            null

    unLoadModule = () ->
        #view.remove()

    #public
    loadModule   : loadModule
    unLoadModule : unLoadModule