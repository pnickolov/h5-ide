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
            view.on 'SWITCH_NEW_STACK_TAB', ( original_tab_id, tab_id ) ->
                console.log 'SWITCH_NEW_STACK_TAB'
                console.log 'original_tab_id = ' + original_tab_id
                console.log 'tab_id          = ' + tab_id
                #call refresh
                model.refresh original_tab_id, tab_id, 'new'

            #listen
            view.on 'SWITCH_STACK_TAB', ( original_tab_id, tab_id ) ->
                console.log 'SWITCH_STACK_TAB'
                console.log 'original_tab_id = ' + original_tab_id
                console.log 'tab_id          = ' + tab_id
                #call refresh
                model.refresh original_tab_id, tab_id, 'stack'

            #listen
            view.on 'SWITCH_APP_TAB', ( original_tab_id, tab_id ) ->
                console.log 'SWITCH_APP_TAB'
                console.log 'original_tab_id = ' + original_tab_id
                console.log 'tab_id          = ' + tab_id
                #call refresh
                model.refresh original_tab_id, tab_id, 'app'

            #listen
            view.on 'CLOSE_STACK_TAB', ( tab_id ) ->
                console.log 'CLOSE_STACK_TAB'
                console.log 'tab_id          = ' + tab_id
                #model
                model.delete tab_id

            #listen open_stack
            model.on 'NEW_STACK', ( result ) ->
                console.log 'NEW_STACK'
                #push event
                ide_event.trigger ide_event.SWITCH_TAB, null

            #listen open_stack
            model.on 'OPEN_STACK', ( result ) ->
                console.log 'OPEN_STACK'
                #call getStackInfo
                model.once 'GET_STACK_COMPLETE', ( result ) ->
                    console.log 'GET_STACK_COMPLETE'
                    #push event
                    ide_event.trigger ide_event.SWITCH_TAB, null
                #
                model.getStackInfo result

            #listen old_stack
            model.on 'OLD_STACK', ( result ) ->
                console.log 'OLD_STACK'
                #push event
                ide_event.trigger ide_event.SWITCH_TAB, null

            #listen open_app
            model.on 'OPEN_APP', ( result ) ->
                console.log 'OPEN_APP'
                #call getAppInfo
                model.once 'GET_APP_COMPLETE', ( result ) ->
                    console.log 'GET_APP_COMPLETE'
                    #push event
                    ide_event.trigger ide_event.SWITCH_TAB, null
                #
                model.getAppInfo result

            #listen old_stack
            model.on 'OLD_APP', ( result ) ->
                console.log 'OLD_APP'
                #push event
                ide_event.trigger ide_event.SWITCH_TAB, null

            #listen open stack tab
            ide_event.onLongListen ide_event.OPEN_STACK_TAB, ( tab_name, region_name, stack_id ) ->
                console.log 'OPEN_STACK_TAB ' + ' tab_name = ' + tab_name + ', region_name = ' + region_name + ', stack_id = ' + stack_id
                #set vo
                model.set 'stack_region_name', region_name
                #tabbar api
                Tabbar.open stack_id.toLowerCase(), tab_name + ' - stack'
                null

            #listen add empty tab
            ide_event.onLongListen ide_event.ADD_STACK_TAB, ( region_name ) ->
                console.log 'ADD_STACK_TAB'
                console.log region_name
                #tabbar api
                Tabbar.add 'new-' + MC.data.untitled + '-' + region_name, 'untitled - ' + MC.data.untitled
                #MC.data.untitled ++
                MC.data.untitled = MC.data.untitled + 1
                null

            #listen add app tab
            ide_event.onLongListen ide_event.OPEN_APP_TAB, ( tab_name, region_name, app_id ) ->
                console.log 'OPEN_APP_TAB ' + ' tab_name = ' + tab_name + ', region_name = ' + region_name + ', app_id = ' + app_id
                #set vo
                model.set 'app_region_name', region_name
                #tabbar api
                Tabbar.open app_id.toLowerCase(), tab_name + ' - app'
                null

            #listen
            ide_event.onLongListen 'APP_RUN', ( app_id, tab_name ) ->
                console.log 'APP_RUN ' + ' tab_name = ' + tab_name + ', app_id = ' + app_id
                #
                view.changeIcon app_id
                #push event
                ide_event.trigger 'UPDATE_APP_LIST', null
                null

            #listen
            ide_event.onLongListen 'STOP_RUN', ( app_id, tab_name ) ->
                console.log 'STOP_RUN ' + ' tab_name = ' + tab_name + ', app_id = ' + app_id
                #
                view.changeIcon app_id
                #push event
                ide_event.trigger 'UPDATE_APP_LIST', null
                null

            #listen
            ide_event.onLongListen 'APP_TERMINAL', ( app_id, tab_name ) ->
                console.log 'APP_TERMINAL ' + ' tab_name = ' + tab_name + ', app_id = ' + app_id
                #
                view.closeTab app_id
                #push event
                ide_event.trigger 'UPDATE_APP_LIST', null
                null

            #listen
            ide_event.onLongListen 'STACK_DELETE', ( stack_id, tab_name ) ->
                console.log 'STACK_DELETE ' + ' tab_name = ' + tab_name + ', app_id = ' + stack_id
                #
                view.closeTab stack_id
                #push event
                ide_event.trigger 'UPDATE_STACK_LIST', null
                null

            #render
            view.render()

    unLoadModule = () ->
        #view.remove()

    #public
    loadModule   : loadModule
    unLoadModule : unLoadModule