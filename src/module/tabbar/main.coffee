####################################
#  Controller for tabbar module
####################################

define [ 'jquery', 'text!/module/tabbar/template.html', 'event', 'UI.tabbar' ], ( $, template, ide_event ) ->

    #private
    loadModule = () ->

        #add handlebars script
        template = '<script type="text/x-handlebars-template" id="tabbar-tmpl">' + template + '</script>'

        #load remote html template
        $( template ).appendTo '#tab-bar'

        #load remote module1.js
        require [ './module/tabbar/view', './module/tabbar/model', 'MC' ], ( View, model, MC ) ->

            #view
            view       = new View()

            #listen
            view.on 'SWITCH_DASHBOARD', ( target ) ->
                console.log 'SWITCH_DASHBOARD ' + ' tab_name = ' + target
                #push event
                ide_event.trigger ide_event.SWITCH_DASHBOARD, null

            #listen
            view.on 'SWITCH_STACK_TAB', ( original_tab_id, tab_id ) ->
                console.log 'SWITCH_STACK_TAB'
                console.log 'original_tab_id = ' + original_tab_id
                console.log 'tab_id          = ' + tab_id
                #call refresh
                model.refresh original_tab_id, tab_id

            #listen
            view.on 'CLOSE_STACK_TAB', ( tab_id ) ->
                console.log 'CLOSE_STACK_TAB'
                console.log 'tab_id          = ' + tab_id
                #model
                model.delete tab_id

            #listen open_stack
            model.on 'OPEN_STACK', ( result ) ->
                console.log 'OPEN_STACK'
                #call getStackInfo
                model.once 'GET_STACK_COMPLETE', ( result ) ->
                    console.log 'GET_STACK_COMPLETE'
                    #push event
                    ide_event.trigger ide_event.SWITCH_STACK_TAB, null
                #
                model.getStackInfo result

            #listen old_stack
            model.on 'OLD_STACK', ( result ) ->
                console.log 'OLD_STACK'

            #listen open stack tab
            ide_event.onLongListen ide_event.OPEN_STACK_TAB, ( tab_name, region_name ) ->
                console.log 'OPEN_STACK_TAB ' + ' tab_name = ' + tab_name + ' region_name = ' + region_name
                #set vo
                model.set 'stack_region_name', region_name
                #tabbar api
                Tabbar.open tab_name.toLowerCase(), tab_name + ' - stack'

            #listen add empty tab
            ide_event.onLongListen ide_event.ADD_STACK_TAB, () ->
                console.log 'ADD_STACK_TAB'
                #tabbar api
                Tabbar.add MC.data.untitled, 'untitled - ' + MC.data.untitled
                #MC.data.untitled ++
                MC.data.untitled = MC.data.untitled + 1
                null

            #render
            view.render()

    unLoadModule = () ->
        #view.remove()

    #public
    loadModule   : loadModule
    unLoadModule : unLoadModule