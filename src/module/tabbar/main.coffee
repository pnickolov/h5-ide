####################################
#  Controller for tabbar module
####################################

define [ 'jquery', 'event', 'base_main',
         'constant'
         'UI.tabbar', 'UI.modal'
], ( $, ide_event, base_main, constant ) ->

    #private
    initialize = ->
        #extend parent
        _.extend this, base_main

        #add handlebars script
        #template = '<script type="text/x-handlebars-template" id="tabbar-tmpl">' + template + '</script>'
        #load remote html template
        #$( template ).appendTo '#tab-bar'

        null

    initialize()

    #private
    loadModule = () ->

        #load
        require [ 'tabbar_view', 'tabbar_model' ], ( View, model ) ->

            #view
            #view       = new View()

            view = loadSuperModule loadModule, 'tabbar', View, null
            return if !view

            #############################
            #  view
            #############################

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
            view.on 'SELECE_PLATFORM', ( platform ) ->
                console.log 'SELECE_PLATFORM'
                console.log 'platform          = ' + platform
                console.log 'region_name       = ' + view.temp_region_name

                model.set 'stack_region_name', view.temp_region_name
                model.set 'current_platform', platform

                if MC.data.untitled is 0 and MC.forge.cookie.getCookieByName( 'state' ) is '3'
                    require [ 'component/tutorial/main' ], ( tutorial_main ) -> tutorial_main.loadModule()

                # check repeat stack name
                loop
                    MC.data.untitled = MC.data.untitled + 1
                    break if MC.aws.aws.checkStackName null, 'untitled-'+MC.data.untitled

                Tabbar.add 'new-' + MC.data.untitled + '-' + view.temp_region_name, 'untitled-' + MC.data.untitled + ' - stack'
                modal.close()

            #############################
            #  model
            #############################

            #listen dashboard
            model.on 'SWITCH_DASHBOARD', ( result ) ->
                console.log 'SWITCH_DASHBOARD'
                #push event
                ide_event.trigger ide_event.SWITCH_DASHBOARD, null

            #listen open_process
            model.on 'OPEN_PROCESS', ( tab_id ) ->
                console.log 'OPEN_PROCESS'
                #push event
                #ide_event.trigger ide_event.SWITCH_APP_PROCESS, 'OPEN_PROCESS', tab_id
                ide_event.trigger ide_event.SWITCH_APP_PROCESS, tab_id
                #
                ide_event.trigger ide_event.UPDATE_DESIGN_TAB_ICON, 'pending', tab_id

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

            #listen old_app
            model.on 'OLD_APP', ( tab_id ) ->
                console.log 'OLD_APP'
                #push event
                ide_event.trigger ide_event.SWITCH_TAB, 'OLD_APP', tab_id

            #listen
            model.on 'SAVE_DESIGN_MODULE', ( tab_id ) ->
                console.log 'SAVE_DESIGN_MODULE', tab_id
                ide_event.trigger ide_event.ADD_TAB_DATA, tab_id

            #############################
            #  private method
            #############################

            # new_stack
            newStack = ( tab_id ) ->
                console.log 'NEW_STACK'
                console.log model.get 'stack_region_name'
                console.log model.get 'current_platform'
                console.log model.get 'tab_name'
                console.log tab_id

                ide_event.trigger ide_event.SWITCH_LOADING_BAR, tab_id
                ide_event.trigger ide_event.SWITCH_TAB, 'NEW_STACK' , model.get( 'tab_name' ).replace( ' - stack', '' ), model.get( 'stack_region_name' ), tab_id, model.get 'current_platform'
                ide_event.trigger ide_event.UPDATE_DESIGN_TAB_ICON, 'stack', tab_id

                MC.data.nav_new_stack_list[ tab_id ] = { region : model.get( 'stack_region_name' ) }

                null

            # open_stack
            openStack = ( tab_id ) ->
                console.log 'OPEN_STACK'

                model.once 'GET_STACK_COMPLETE', ( result ) ->
                    console.log 'GET_STACK_COMPLETE'
                    console.log result
                    ide_event.trigger ide_event.SWITCH_TAB, 'OPEN_STACK', tab_id, model.get( 'stack_region_name' ), result, result.resolved_data[0].platform
                    ide_event.trigger ide_event.UPDATE_DESIGN_TAB_ICON, 'stack', tab_id
                model.getStackInfo tab_id

                ide_event.trigger ide_event.SWITCH_LOADING_BAR, tab_id

                null

            # open_app
            openApp = ( tab_id ) ->
                console.log 'OPEN_APP'

                model.once 'GET_APP_COMPLETE', ( result ) ->
                    console.log 'GET_APP_COMPLETE'
                    console.log result
                    ide_event.trigger ide_event.SWITCH_TAB, 'OPEN_APP', tab_id, result.resolved_data[0].region, result, result.resolved_data[0].platform
                    ide_event.trigger ide_event.UPDATE_DESIGN_TAB_ICON, result.resolved_data[0].state, tab_id
                model.getAppInfo tab_id

                ide_event.trigger ide_event.SWITCH_LOADING_BAR, tab_id

                null

            model.on 'NEW_STACK',  newStack
            model.on 'OPEN_STACK', openStack
            model.on 'OPEN_APP',   openApp

            # new stack
            newStackTab = ( region_name ) ->
                console.log 'ADD_STACK_TAB'
                console.log region_name
                view.temp_region_name = region_name
                platformSupport = model.checkPlatform( region_name )
                if platformSupport is true
                    modal MC.template.createNewStackClassic(), true
                else if  platformSupport is false
                    modal MC.template.createNewStackVPC(), true
                else
                    modal MC.template.createNewStackErrorAndReload(), true
                null

            # open stack
            openStackTab = ( tab_name, region_name, stack_id ) ->
                console.log 'OPEN_STACK_TAB ' + ' tab_name = ' + tab_name + ', region_name = ' + region_name + ', stack_id = ' + stack_id
                model.set 'stack_region_name', region_name
                Tabbar.open stack_id.toLowerCase(), tab_name + ' - stack'
                #
                if _.contains( MC.data.demo_stack_list, tab_name ) and MC.forge.cookie.getCookieByName( 'state' ) is '3'
                    require [ 'component/tutorial/main' ], ( tutorial_main ) -> tutorial_main.loadModule()
                null

            # open app
            openAppTab = ( tab_name, region_name, app_id ) ->
                console.log 'OPEN_APP_TAB ' + ' tab_name = ' + tab_name + ', region_name = ' + region_name + ', app_id = ' + app_id
                model.set 'app_region_name', region_name
                Tabbar.open app_id.toLowerCase(), tab_name + ' - app'
                null

            # new process
            newProcessTab = ( tab_id, tab_name, region ) ->
                console.log 'OPEN_APP_PROCESS_TAB, tab_id = ' + tab_id + ', tab_name = ' + tab_name + ', region_name = ' + region
                process_name = 'process-' + region + '-' + tab_name
                MC.process[ process_name ] = { 'tab_id' : tab_id, 'app_name' : tab_name, 'region' : region, 'flag_list' : {'is_pending':true} }
                Tabbar.add process_name, tab_name + ' - app'

            #listen
            reloadNewStackTab = ( tab_id, region_name, platform ) ->
                console.log 'RELOAD_NEW_STACK_TAB', tab_id, region_name, platform
                model.set 'tab_name',          tab_id
                model.set 'stack_region_name', region_name
                model.set 'current_platform',  platform
                newStack tab_id

            # reload stack
            reloadStackTab = ( tab_id, region_name ) ->
                console.log 'RELOAD_STACK_TAB', tab_id, region_name
                model.set 'stack_region_name', region_name
                openStack tab_id

            # reload app
            reloadAppTab = ( tab_id, region_name ) ->
                console.log 'PROCESS_RUN_SUCCESS, tab_id = ' + tab_id + ', region_name = ' + region_name
                model.set 'app_region_name', region_name
                openApp tab_id

            #############################
            #  listen tab
            #############################

            # open tab
            # type: 'NEW_STACK' 'OPEN_STACK' 'OPEN_APP' 'NEW_PROCESS' 'RELOAD_STACK' 'RELOAD_NEW_STACK' 'RELOAD_APP'
            ide_event.onLongListen ide_event.OPEN_DESIGN_TAB, ( type, tab_name, region_name, tab_id ) ->
                console.log 'OPEN_DESIGN_TAB', type, tab_name, region_name, tab_id
                switch type

                    when 'NEW_STACK'        then newStackTab       region_name

                    when 'OPEN_STACK'       then openStackTab      tab_name, region_name, tab_id
                    when 'OPEN_APP'         then openAppTab        tab_name, region_name, tab_id

                    when 'NEW_PROCESS'      then newProcessTab     tab_id,   tab_name,    region_name

                    when 'RELOAD_STACK'     then reloadStackTab    tab_id,   region_name
                    when 'RELOAD_APP'       then reloadAppTab      tab_id,   region_name

                    # when RELOAD_NEW_STACK tab_name is platform
                    when 'RELOAD_NEW_STACK' then reloadNewStackTab tab_id, region_name, tab_name

                    else
                        console.log 'open undefined tab'

            # close current tab
            ide_event.onLongListen ide_event.CLOSE_DESIGN_TAB, ( tab_id ) ->
                console.log 'CLOSE_DESIGN_TAB', tab_id
                view.closeTab tab_id
                null

            # update current tab name id
            ide_event.onLongListen ide_event.UPDATE_DESIGN_TAB, ( tab_id, tab_name ) ->
                console.log 'UPDATE_DESIGN_TAB, tab_id = ' + tab_id + ', tab_name = ' + tab_name

                # set current tab id
                MC.forge.other.setCurrentTabId tab_id

                # get origin tab id and reset tab_id and tab_name
                original_tab_id = view.updateCurrentTab tab_id, tab_name
                console.log original_tab_id

                # update MC.tab include ADD_TAB_DATA and DELETE_TAB_DATA
                if original_tab_id isnt tab_id
                    ide_event.trigger ide_event.ADD_TAB_DATA,    tab_id
                    ide_event.trigger ide_event.DELETE_TAB_DATA, original_tab_id

                null

            # update Tabbar.current
            ide_event.onLongListen ide_event.UPDATE_DESIGN_TAB_TYPE, ( tab_id, tab_type ) ->
                console.log 'UPDATE_DESIGN_TAB_TYPE, tab_id = ' + tab_id + ', tab_type = ' + tab_type
                Tabbar.updateState tab_id, tab_type

            #############################
            #  listen dashboard
            #############################

            #listen open dashboard
            ide_event.onLongListen ide_event.NAVIGATION_TO_DASHBOARD_REGION, () ->
                console.log 'NAVIGATION_TO_DASHBOARD_REGION'
                Tabbar.open 'dashboard'
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

            #############################
            #  listen other
            #############################

            #listen
            ide_event.onLongListen ide_event.UPDATE_APP_STATE, ( type, tab_id ) ->
                console.log 'tabbar:UPDATE_APP_STATE', type, tab_id
                if type is constant.APP_STATE.APP_STATE_TERMINATED
                    ide_event.trigger ide_event.CLOSE_DESIGN_TAB, tab_id
                null

            #############################
            #  view
            #############################

            #render
            view.render()

    unLoadModule = () ->
        #view.remove()

    #public
    loadModule   : loadModule
    unLoadModule : unLoadModule
