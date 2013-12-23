####################################
#  Controller for design module
####################################

define [ 'i18n!nls/lang.js', 'constant', './module/design/framework/test' ], ( lang, constant ) ->

    #private
    loadModule = () ->

        #load remote design.js
        require [ 'design_view', 'design_model', 'property', 'event' ], ( View, model, property_main, ide_event ) ->

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
            view.render()

            #listen DESIGN_SUB_COMPLETE
            ide_event.onLongListen ide_event.DESIGN_SUB_COMPLETE, () ->
                console.log 'design:DESIGN_SUB_COMPLETE = ' + MC.data.design_submodule_count
                if MC.data.design_submodule_count is 3
                    design_view_init = view.$el.html()
                    MC.data.design_submodule_count = -1
                    #push event
                    ide_event.trigger ide_event.DESIGN_COMPLETE
                    ide_event.trigger ide_event.IDE_AVAILABLE
                    #off DESIGN_SUB_COMPLETE
                    ide_event.offListen ide_event.DESIGN_SUB_COMPLETE
                else
                    MC.data.design_submodule_count = MC.data.design_submodule_count + 1
                null

<<<<<<< HEAD
            #listen SAVE_DESIGN_MODULE
            ide_event.onLongListen ide_event.SAVE_DESIGN_MODULE, ( tab_id ) ->
                console.log 'design:SAVE_DESIGN_MODULE = ' + tab_id
                #save tab
                if tab_id.split( '-' )[0] is 'process'
                    model.saveProcessTab tab_id
                else
                    model.saveTab tab_id,
                                  view.html(),
                                  model.getCanvasData(),
                                  model.getCanvasProperty(),
                                  property_main.snapshot(),
                                  model.getOriginData(),
                                  model.getTAValidation(),
                                  model.getDesignModel()
=======
            # ADD_TAB_DATA
            ide_event.onLongListen ide_event.ADD_TAB_DATA, ( tab_id ) ->
                console.log 'ADD_TAB_DATA = ' + tab_id

                try

                    # only include 'new-xxx' | 'stack-xxx' | 'app-xxx' | 'appview-xxx'
                    if tab_id.split( '-' )[0] not in [ 'process' ]
                        model.addTab tab_id,
                                     view.html(),
                                     model.getCanvasData(),
                                     model.getCanvasProperty(),
                                     property_main.snapshot(),
                                     model.getOriginData(),
                                     model.getTAValidation()

                catch error
                  console.log 'ADD_TAB_DATA error, current tab id is ' + tab_id
                  console.log "error message: #{ error }"

                null

            # DELETE_TAB_DATA
            ide_event.onLongListen ide_event.DELETE_TAB_DATA, ( tab_id ) ->
                console.log 'DELETE_TAB_DATA, tab_id = ' + tab_id
                model.deleteTab tab_id
>>>>>>> develop
                null

            # SWITCH_TAB
            ide_event.onLongListen ide_event.SWITCH_TAB, ( type, tab_id, region_name, result, current_platform ) ->

                try

                    console.log 'design:SWITCH_TAB', type, tab_id, region_name, result, current_platform

                    # new stack store MC.open_failed_list
                    # when 'NEW_STACK' result is tab_id
                    if type in [ 'NEW_STACK' ]
                        MC.open_failed_list[ MC.data.current_tab_id ] = { 'id' : tab_id, 'region' : region_name, 'platform' : current_platform, 'type' : type }

                    # restore old tab
                    if type in [ 'OLD_STACK', 'OLD_APP' ] then model.getTab type, tab_id else view.$el.html design_view_init

                    # new stack | open stack | open app
                    if type in [ 'NEW_STACK', 'OPEN_STACK', 'OPEN_APP' ]

                        if result and result.resolved_data and result.resolved_data.length is 0
                            console.log 'current tab inexistence', type, tab_id, region_name, result, current_platform
                            return

                        if type in [ 'OPEN_STACK', 'OPEN_APP' ]

                            #set MC.canvas_data
                            model.setCanvasData result.resolved_data[0]

                        if type is 'OPEN_APP'

                            if Tabbar.current isnt 'appview'
                                #get all resource data for app
                                model.getAppResourcesService region_name, tab_id

                        if type is 'OPEN_STACK'

                            #get all not exist ami data for stack
                            model.getAllNotExistAmiInStack region_name, tab_id

                        #when NEW_STACK result is tab_id
                        ide_event.trigger ide_event.OPEN_DESIGN, region_name, type, current_platform, tab_id, result

                        # Instead of posting a ide_event.OPEN_DESIGN to let property panel to figure it out what to do, here directly tells it to open a stack property.
                        ide_event.trigger ide_event.OPEN_PROPERTY, "component", ""

                    # setting app state
                    if type in [ 'OPEN_APP', 'OLD_APP' ]

                        console.log 'when open_app or old_app restore the scene'

                        # update design-overlay when app changed
                        if MC.data.process[ tab_id ] and MC.data.process[ tab_id ].flag_list

                            # changed success
                            if MC.data.process[ tab_id ].flag_list.is_updated

                                if type is 'OLD_APP'
                                    ide_event.trigger ide_event.SHOW_DESIGN_OVERLAY, 'UPDATING_SUCCESS', tab_id
                                else
                                    MC.forge.other.deleteProcess tab_id

                            # changed done
                            else if MC.data.process[ tab_id ].flag_list.is_done
                                ide_event.trigger ide_event.HIDE_DESIGN_OVERLAY

                            # changed fail
                            else if MC.data.process[ tab_id ].flag_list.is_failed

                                if type is 'OLD_APP'
                                    ide_event.trigger ide_event.SHOW_DESIGN_OVERLAY, 'CHANGED_FAIL', tab_id
                                else
                                    # don't do anything

                            # upading
                            else if MC.data.process[ tab_id ].flag_list.flag is 'UPDATE_APP'
                                ide_event.trigger ide_event.SHOW_DESIGN_OVERLAY, constant.APP_STATE.APP_STATE_UPDATING, tab_id

                            # staring stopping terminating
                            else if MC.data.process[ tab_id ].flag_list.flag in [ 'START_APP', 'STOP_APP', 'TERMINATE_APP' ]

                                ide_event.trigger ide_event.SHOW_DESIGN_OVERLAY, model.returnAppState( MC.data.process[ tab_id ].flag_list.flag, MC.data.process[ tab_id ].state ), tab_id

                        else

                            # F5 ide restore overlay
                            state = MC.forge.other.filterProcess tab_id
                            if state
                                ide_event.trigger ide_event.SHOW_DESIGN_OVERLAY, state, tab_id
                            else
                                console.log 'current tab not found state'

                    # show OPEN_TAB_FAIL
                    if type in [ 'OLD_APP', 'OLD_STACK' ] and MC.open_failed_list[ tab_id ]
                        ide_event.trigger ide_event.SHOW_DESIGN_OVERLAY, 'OPEN_TAB_FAIL', tab_id

                    # hide status bar
                    view.hideStatusbar()

                catch error
                    ### env:dev ###
                    throw error
                    ### env:dev:end ###

                null

            #listen
            ide_event.onLongListen ide_event.UPDATE_APP_STATE, ( type, id ) ->
                console.log 'design:UPDATE_APP_STATE', type, id

                #MC.data.process             = {}
                #MC.data.process             = $.extend true, {}, MC.process
                #MC.data.process[ id ].state = type if MC.data.process and MC.data.process[ id ]

                # set MC.data.process when MC.data.process is {} return
                if _.isEmpty MC.forge.other.initDataProcess id, type, MC.process
                    return

                # not current tab return
                if MC.data.current_tab_id isnt id
                    return

                # update success
                if MC.process[ id ].flag_list and MC.process[ id ].flag_list.is_updated
                    ide_event.trigger ide_event.SHOW_DESIGN_OVERLAY, 'UPDATING_SUCCESS', id

                # changed
                else if type in [ constant.APP_STATE.APP_STATE_RUNNING, constant.APP_STATE.APP_STATE_STOPPED, constant.APP_STATE.APP_STATE_TERMINATED ]
                    ide_event.trigger ide_event.HIDE_DESIGN_OVERLAY

                # changed fail
                else if MC.process[ id ].flag_list and MC.process[ id ].flag_list.is_failed
                    ide_event.trigger ide_event.SHOW_DESIGN_OVERLAY, 'CHANGED_FAIL', id

                # changing
                else if type in [ constant.APP_STATE.APP_STATE_STARTING, constant.APP_STATE.APP_STATE_STOPPING, constant.APP_STATE.APP_STATE_TERMINATING, constant.APP_STATE.APP_STATE_UPDATING ]
                    ide_event.trigger ide_event.SHOW_DESIGN_OVERLAY, type, id

                null

            #listen
            ide_event.onLongListen ide_event.UPDATE_APP_INFO, ( region_name, app_id ) ->
                console.log 'UPDATE_APP_INFO', region_name, app_id

                setTimeout ->
                    # app update fail
                    if MC.data.process[app_id] and MC.data.process[ app_id ].flag_list.is_failed
                        return

                    # invoke app info
                    model.appInfoService region_name, app_id
                , 200

                null

            #listen
            ide_event.onLongListen ide_event.UPDATE_APP_RESOURCE, ( region_name, app_id ) ->
                console.log 'UPDATE_APP_RESOURCE', region_name, app_id
                ide_event.trigger ide_event.SWITCH_LOADING_BAR, null, true
                model.getAppResourcesService region_name, app_id
                null

            #listen
            ide_event.onLongListen ide_event.UPDATE_STATUS_BAR, ( type, level ) ->
                view.updateStatusbar type, level

            ide_event.onLongListen ide_event.UPDATE_STATUS_BAR_SAVE_TIME, ( ) ->
                view.updateStatusBarSaveTime()

            ide_event.onLongListen ide_event.UPDATE_RESOURCE_STATE, () ->
                view.hideStatusbar()

            model.on "SET_PROPERTY_PANEL", ( property_panel ) ->
                property_main.restore property_panel
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
