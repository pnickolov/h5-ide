####################################
#  Controller for tabbar module
####################################

define [ 'jquery', 'text!./module/tabbar/template.html', 'event', 'UI.tabbar', 'UI.modal' ], ( $, template, ide_event ) ->

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

            #temp
            #MC.data.event = ide_event

            #listen
            view.on 'SWITCH_DASHBOARD', ( original_tab_id, tab_id ) ->
                console.log 'SWITCH_DASHBOARD'
                console.log 'original_tab_id = ' + original_tab_id
                console.log 'tab_id          = ' + tab_id
                #call refresh
                model.refresh original_tab_id, tab_id, 'dashboard'

            #listen
            view.on 'SWITCH_NEW_STACK_TAB', ( original_tab_id, tab_id, tab_name ) ->
                console.log 'SWITCH_NEW_STACK_TAB'
                console.log 'original_tab_id = ' + original_tab_id
                console.log 'tab_id          = ' + tab_id
                console.log 'tab_name        = ' + tab_name
                #
                model.set 'tab_name', tab_name
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
            view.on 'SWTICH_PROCESS_TAB', ( original_tab_id, tab_id ) ->
                console.log 'SWTICH_PROCESS_TAB'
                console.log 'original_tab_id = ' + original_tab_id
                console.log 'tab_id          = ' + tab_id
                #call refresh
                model.refresh original_tab_id, tab_id, 'process'

            #listen
            view.on 'CLOSE_STACK_TAB', ( tab_id ) ->
                console.log 'CLOSE_STACK_TAB'
                console.log 'tab_id          = ' + tab_id
                #model
                #$model.delete tab_id
                ide_event.trigger ide_event.DELETE_TAB_DATA, tab_id

            #listen
            view.on 'SELECE_PLATFORM', ( platform ) ->
                console.log 'SELECE_PLATFORM'
                console.log 'platform          = ' + platform
                console.log 'region_name       = ' + view.temp_region_name
                #set vo
                model.set 'stack_region_name', view.temp_region_name
                #set current platform
                model.set 'current_platform', platform
                # track
                analytics.track "Created Stack",
                    stack_type: platform,
                    stack_region: view.temp_region_name
                #tabbar api
                Tabbar.add 'new-' + MC.data.untitled + '-' + view.temp_region_name, 'untitled-' + MC.data.untitled
                #MC.data.untitled ++
                MC.data.untitled = MC.data.untitled + 1
                #
                modal.close()

            #listen dashboard
            model.on 'SWITCH_DASHBOARD', ( result ) ->
                console.log 'SWITCH_DASHBOARD'
                #push event
                ide_event.trigger ide_event.SWITCH_DASHBOARD, null

            #listen new_stack
            model.on 'NEW_STACK', ( tab_id ) ->
                console.log 'NEW_STACK'
                console.log model.get 'stack_region_name'
                console.log model.get 'current_platform'
                console.log model.get 'tab_name'
                console.log tab_id
                #push event
                ide_event.trigger ide_event.SWITCH_TAB, 'NEW_STACK' , model.get( 'tab_name' ), model.get( 'stack_region_name' ), tab_id, model.get 'current_platform'
                #
                ide_event.trigger ide_event.UPDATE_TAB_ICON, 'stack', tab_id
                #
                ide_event.trigger ide_event.SWITCH_LOADING_BAR, tab_id

            #listen open_stack
            model.on 'OPEN_STACK', ( tab_id ) ->
                console.log 'OPEN_STACK'
                #call getStackInfo
                model.once 'GET_STACK_COMPLETE', ( result ) ->
                    console.log 'GET_STACK_COMPLETE'
                    console.log result
                    #push event
                    ide_event.trigger ide_event.SWITCH_TAB, 'OPEN_STACK', tab_id, model.get( 'stack_region_name' ), result, result.resolved_data[0].platform
                    #
                    ide_event.trigger ide_event.UPDATE_TAB_ICON, 'stack', tab_id
                #
                model.getStackInfo tab_id
                #
                ide_event.trigger ide_event.SWITCH_LOADING_BAR, tab_id

            #listen open_app
            openApp = ( tab_id ) ->
                console.log 'OPEN_APP'
                #call getAppInfo
                model.once 'GET_APP_COMPLETE', ( result ) ->
                    console.log 'GET_APP_COMPLETE'
                    console.log result
                    #push event
                    ide_event.trigger ide_event.SWITCH_TAB, 'OPEN_APP', tab_id, result.resolved_data[0].region, result, result.resolved_data[0].platform
                    #
                    ide_event.trigger ide_event.UPDATE_TAB_ICON, result.resolved_data[0].state, tab_id
                #
                model.getAppInfo tab_id
                #
                ide_event.trigger ide_event.SWITCH_LOADING_BAR, tab_id
            model.on 'OPEN_APP', openApp

            #listen open_process
            model.on 'OPEN_PROCESS', ( tab_id ) ->
                console.log 'OPEN_PROCESS'
                #push event
                #ide_event.trigger ide_event.SWITCH_APP_PROCESS, 'OPEN_PROCESS', tab_id
                ide_event.trigger ide_event.SWITCH_APP_PROCESS, tab_id
                #
                ide_event.trigger ide_event.UPDATE_TAB_ICON, 'pending', tab_id

            #listen old_app
            model.on 'OLD_APP', ( tab_id ) ->
                console.log 'OLD_APP'
                #push event
                ide_event.trigger ide_event.SWITCH_TAB, 'OLD_APP', tab_id

            #listen old_stack
            model.on 'OLD_STACK', ( tab_id ) ->
                console.log 'OLD_STACK'
                #push event
                ide_event.trigger ide_event.SWITCH_TAB, 'OLD_STACK', tab_id

            #listen old_process
            model.on 'OLD_PROCESS', ( tab_id ) ->
                console.log 'OLD_PROCESS'
                #push event
                #ide_event.trigger ide_event.SWITCH_APP_PROCESS, 'OLD_PROCESS', tab_id
                ide_event.trigger ide_event.SWITCH_APP_PROCESS, tab_id

            #listen
            model.on 'SAVE_DESIGN_MODULE', ( tab_id ) ->
                console.log 'SAVE_DESIGN_MODULE'
                console.log 'tab_id          = ' + tab_id
                #push event
                ide_event.trigger ide_event.SAVE_DESIGN_MODULE, tab_id

            #listen open dashboard
            ide_event.onLongListen ide_event.NAVIGATION_TO_DASHBOARD_REGION, () ->
                console.log 'NAVIGATION_TO_DASHBOARD_REGION'
                Tabbar.open 'dashboard'
                null

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
                #
                view.temp_region_name = region_name
                #
                if model.checkPlatform( region_name )
                    modal MC.template.createNewStackClassic(), true
                else
                    modal MC.template.createNewStackVPC(), true
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
            ide_event.onLongListen ide_event.STARTED_APP, ( tab_name, app_id ) ->
                console.log 'START_APP ' + ' tab_name = ' + tab_name + ', app_id = ' + app_id
                #
                view.changeIcon app_id
                #push event
                ide_event.trigger ide_event.UPDATE_APP_LIST, null
                null

            #listen
            ide_event.onLongListen ide_event.STOPPED_APP, ( tab_name, app_id ) ->
                console.log 'STOP_APP ' + ' tab_name = ' + tab_name + ', app_id = ' + app_id
                #
                view.changeIcon app_id
                #push event
                ide_event.trigger ide_event.UPDATE_APP_LIST, null
                null

            #listen
            ide_event.onLongListen ide_event.TERMINATED_APP, ( tab_name, app_id ) ->
                console.log 'APP_TERMINAL ' + ' tab_name = ' + tab_name + ', app_id = ' + app_id
                #
                view.closeTab app_id
                #push event
                ide_event.trigger ide_event.UPDATE_APP_LIST, null
                null

            #listen
            ide_event.onLongListen ide_event.STACK_DELETE, ( tab_name, stack_id ) ->
                console.log 'STACK_DELETE ' + ' tab_name = ' + tab_name + ', stack_id = ' + stack_id
                #
                view.closeTab stack_id
                #push event
                ide_event.trigger ide_event.UPDATE_STACK_LIST, null
                null

            #listen
            ide_event.onLongListen ide_event.RETURN_REGION_TAB, ( region ) ->
                console.log 'RETURN_REGION_TAB ' + ' region = ' + region
                view.changeDashboardTabname region
                null

            #listen
            ide_event.onLongListen ide_event.RETURN_OVERVIEW_TAB, () ->
                console.log 'RETURN_OVERVIEW_TAB '
                view.changeDashboardTabname 'Global'
                null

            #listen
            ide_event.onLongListen ide_event.UPDATE_TABBAR, ( tab_id, tab_name ) ->
                console.log 'UPDATE_TABBAR, tab_id = ' + tab_id + ', tab_name = ' + tab_name
                original_tab_id = view.updateCurrentTab tab_id, tab_name
                console.log original_tab_id
                if tab_id.split( '-' )[0] isnt 'app'
                    if original_tab_id isnt tab_id then ide_event.trigger ide_event.UPDATE_TAB_DATA, original_tab_id, tab_id

            #listen
            ide_event.onLongListen ide_event.OPEN_APP_PROCESS_TAB, ( tab_id, tab_name, region, result ) ->
                console.log 'OPEN_APP_PROCESS_TAB, tab_id = ' + tab_id + ', tab_name = ' + tab_name + ', region_name = ' + region
                #set vo
                #model.set 'app_region_name', region_name
                #
                process_name = 'process-' + region + '-' + tab_name
                MC.process[ process_name ] = { 'tab_id' : tab_id, 'app_name' : tab_name, 'region' : region, 'flag_list' : {'is_pending':true} }
                #tabbar api
                Tabbar.add process_name.toLowerCase(), tab_name + ' - app'

            #listen
            ide_event.onLongListen ide_event.PROCESS_RUN_SUCCESS, ( tab_id, region_name ) ->
                console.log 'PROCESS_RUN_SUCCESS'
                #set vo
                model.set 'app_region_name', region_name
                #
                openApp tab_id

            #render
            view.render()

    unLoadModule = () ->
        #view.remove()

    #public
    loadModule   : loadModule
    unLoadModule : unLoadModule
