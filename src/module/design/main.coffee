####################################
#  Controller for design module
####################################

define [ 'jquery', 'text!/module/design/template.html', 'MC.canvas.constant' ], ( $, template ) ->

    #private
    loadModule = () ->

        #load remote design.js
        require [ './module/design/view', './module/design/model', 'event' ], ( View, model, ide_event ) ->

            #
            design_view_init       = null
            design_submodule_count = 0

            #view
            view       = new View()
            view.listen model

            #listen event
            view.once 'DESIGN_COMPLETE', () ->
                console.log 'view:DESIGN_COMPLETE'
                #wrap 'resource', 'property', 'toolbar', 'canvas'
                wrap()

            #render
            view.render template

            #listen DESIGN_SUB_COMPLETE
            ide_event.onLongListen ide_event.DESIGN_SUB_COMPLETE, () ->
                console.log 'design:DESIGN_SUB_COMPLETE = ' + design_submodule_count
                if design_submodule_count is 3
                    design_view_init = view.$el.html()
                    design_submodule_count = -1
                    #push event
                    ide_event.trigger ide_event.DESIGN_COMPLETE
                else
                    design_submodule_count = design_submodule_count + 1

            #listen SAVE_DESIGN_MODULE
            ide_event.onLongListen ide_event.SAVE_DESIGN_MODULE, ( target ) ->
                console.log 'design:SAVE_DESIGN_MODULE = ' + target
                #save tab
                model.saveTab target, view.$el.html(), model.getCanvasData(), model.getCanvasProperty()
                null

            #listen SWITCH_TAB
            ide_event.onLongListen ide_event.SWITCH_TAB, ( type, target, region_name, stack_info, current_paltform ) ->
                console.log 'design:SWITCH_TAB, type = ' + type + ', target = ' + target + ', region_name = ' + region_name + ', current_paltform = ' + current_paltform
                #save tab
                if type is 'OLD_STACK' or type is 'OLD_APP' then model.readTab type, target else view.$el.html design_view_init
                #
                if type is 'NEW_STACK' or type is 'OPEN_STACK'
                    #
                    if type is 'OPEN_STACK' then model.setCanvasData( stack_info.resolved_data[0] )
                    #temp
                    ide_event.trigger ide_event.RELOAD_RESOURCE, region_name, type, current_paltform, target

                ###
                if type is 'OPEN_APP'
                    #
                null
                ###

            #listen
            ide_event.onLongListen ide_event.DELETE_TAB_DATA, ( tab_id ) ->
                console.log 'DELETE_TAB_DATA, tab_id = ' + tab_id
                model.deleteTab tab_id
            null

            #listen
            ide_event.onLongListen ide_event.UPDATE_TAB_DATA, ( original_tab_id, tab_id ) ->
                console.log 'UPDATE_TAB_DATA, original_tab_id = ' + original_tab_id + ', tab_id = ' + tab_id
                model.updateTab original_tab_id, tab_id
            null

    #private
    unLoadModule = () ->
        #view.remove()

    #private
    wrap = () ->

        require [ 'resource', 'property', 'toolbar', 'canvas' ], ( resource, property, toolbar, canvas ) ->
            #load remote design/resource
            resource.loadModule()

            #load remote design/property
            property.loadModule()

            #load remote design/canvas
            canvas.loadModule()

            #load remote design/toolbar
            toolbar.loadModule()

    #public
    loadModule   : loadModule
    unLoadModule : unLoadModule