####################################
#  Controller for design module
####################################

define [ 'jquery', 'text!/module/design/template.html' ], ( $, template ) ->

    #private
    loadModule = () ->

        #load remote design.js
        require [ './module/design/view', './module/design/model', 'event' ], ( View, model, ide_event ) ->

            #
            design_view_init = null

            #view
            view       = new View()
            view.listen model

            #listen event
            view.once 'DESIGN_COMPLETE', () ->
                console.log 'view:DESIGN_COMPLETE'
                #wrap 'resource', 'property', 'toolbar', 'canvas'
                wrap()
                #push event
                ide_event.trigger ide_event.DESIGN_COMPLETE
                #temp
                setTimeout () ->
                    #load layout
                    console.log 'design_view_init'
                    design_view_init = view.$el.html()
                    null
                , 2000
                null

            #render
            view.render template

            #listen SAVE_DESIGN_MODULE
            ide_event.onLongListen ide_event.SAVE_DESIGN_MODULE, ( target ) ->
                console.log 'design:SAVE_DESIGN_MODULE = ' + target
                #save tab
                model.saveTab target, view.$el.html(), view.$el.find( '#canvas' ).html()
                null

            #listen SWITCH_TAB
            ide_event.onLongListen ide_event.SWITCH_TAB, ( type, target, region_name ) ->
                console.log 'design:SWITCH_TAB, type = ' + type + ', target = ' + target + ', region_name = ' + region_name
                #save tab
                if type is 'OLD_STACK' or type is 'OLD_APP' then model.readTab type, target else view.$el.html design_view_init
                #
                if type is 'NEW_STACK'
                    #push event
                    ide_event.trigger ide_event.RELOAD_RESOURCE, region_name

                #init data when open stack (modify by xjimmy)
                if type is 'OPEN_STACK'
                    #set current tab_id
                    MC.canvas.current_tab = target.param[4][0]
                    #deep clone MC.canvas.STACK_JSON
                    MC.tab[ MC.canvas.current_tab ] = {}
                    MC.tab[ MC.canvas.current_tab ].data = $.extend(true, {}, MC.canvas.STACK_JSON)

                null

                ###
                #
                if type is 'OPEN_APP'
                    #
                null
                ###

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