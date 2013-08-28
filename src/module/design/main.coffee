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
            MC.data.design_submodule_count = 0

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
                console.log 'design:DESIGN_SUB_COMPLETE = ' + MC.data.design_submodule_count
                if MC.data.design_submodule_count is 3
                    design_view_init = view.$el.html()
                    MC.data.design_submodule_count = -1
                    #push event
                    ide_event.trigger ide_event.DESIGN_COMPLETE
                    #off DESIGN_SUB_COMPLETE
                    ide_event.offListen ide_event.DESIGN_SUB_COMPLETE
                else
                    MC.data.design_submodule_count = MC.data.design_submodule_count + 1
                null

            #listen SAVE_DESIGN_MODULE
            ide_event.onLongListen ide_event.SAVE_DESIGN_MODULE, ( tab_id ) ->
                console.log 'design:SAVE_DESIGN_MODULE = ' + tab_id
                #save tab
                if tab_id.split( '-' )[0] is 'process'
                    model.saveProcessTab tab_id
                else
                    model.saveTab tab_id, view.html(), model.getCanvasData(), model.getCanvasProperty(), model.getPropertyPanel(), model.getLastOpenProperty()
                null

            #listen SWITCH_TAB
            ide_event.onLongListen ide_event.SWITCH_TAB, ( type, tab_id, region_name, result, current_platform ) ->
                console.log 'design:SWITCH_TAB, type = ' + type + ', tab_id = ' + tab_id + ', region_name = ' + region_name + ', current_platform = ' + current_platform
                #
                if type is 'OLD_STACK' or type is 'OLD_APP' then model.readTab type, tab_id else view.$el.html design_view_init
                #
                if type is 'NEW_STACK' or type is 'OPEN_STACK' or type is 'OPEN_APP'
                    #
                    ide_event.trigger ide_event.SWITCH_LOADING_BAR, if type is 'NEW_STACK' then result else tab_id
                    #
                    if type is 'OPEN_STACK' or type is 'OPEN_APP'
                        #when OPEN_STACK or OPEN_APP result is resolved_data
                        model.setCanvasData result.resolved_data[0]

                    if type is 'OPEN_APP'
                        #get all resource data for app
                        model.getAppResourcesService region_name, tab_id

                    #temp
                    #when NEW_STACK result is tab_id
                    ide_event.trigger ide_event.OPEN_DESIGN, region_name, type, current_platform, tab_id, result
                null

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

            #listen
            ide_event.onLongListen ide_event.UPDATA_TAB_ICON, ( flag, id, region ) ->
                console.log 'UPDATE_TAB_ICON, flag:' + flag + ', id:' + id
                if id.indexOf('app-') == 0
                    model.getAppResourcesService region_name, id

            null

    #private
    unLoadModule = () ->
        #view.remove()

    #private
    wrap = () ->

        require [ 'resource', 'property', 'toolbar', 'canvas' ], ( resource, property, toolbar, canvas ) ->

            #load remote design/canvas
            canvas.loadModule()

            #load remote design/toolbar
            toolbar.loadModule()

            #load remote design/resource
            resource.loadModule()

            #load remote design/property
            property.loadModule()

    #public
    loadModule   : loadModule
    unLoadModule : unLoadModule