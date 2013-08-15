####################################
#  Controller for design/toolbar module
####################################

define [ 'jquery',
         'text!/module/design/toolbar/stack_template.html',
         'text!/module/design/toolbar/app_template.html',
         'event'
], ( $, stack_template, app_template, ide_event ) ->

    #private
    loadModule = () ->

        #add handlebars script
        stack_template = '<script type="text/x-handlebars-template" id="toolbar-stack-tmpl">' + stack_template + '</script>'
        app_template   = '<script type="text/x-handlebars-template" id="toolbar-app-tmpl">'   + app_template   + '</script>'
        #load remote html template
        $( 'head' ).append stack_template
        $( 'head' ).append app_template

        #
        require [ './module/design/toolbar/view', './module/design/toolbar/model' ], ( View, model ) ->

            #view
            view       = new View()
            view.model = model
            view.render()

            #listen RELOAD_RESOURCE
            ide_event.onLongListen ide_event.RELOAD_RESOURCE, ( region_name, type, current_platform, tab_name, tab_id ) ->
                console.log 'toolbar:RELOAD_RESOURCE, region_name = ' + region_name + ', type = ' + type

                #temp
                setTimeout () ->
                    model.setFlag tab_id, type
                , 500

            #listen toolbar state change
            model.on 'UPDATE_TOOLBAR', (type) ->
                console.log 'update toolbar status'
                view.render type

            ide_event.onLongListen ide_event.SWITCH_DASHBOARD, () ->
                console.log 'SWITCH_DASHBOARD'
                model.setTabFlag(false)
                null

            ide_event.onLongListen ide_event.SWITCH_TAB, () ->
                setTimeout () ->
                    console.log 'SWITCH_TAB toolbar id:' + MC.canvas_data.id
                    model.setTabFlag(true)
                , 500

            # ide_event.onLongListen ide_event.SWITCH_APP_TAB, () ->
            #     console.log 'SWITCH_APP_TAB'
            #     model.setTabFlag(true)
            #     null

            # ide_event.onLongListen ide_event.SWITCH_STACK_TAB, () ->
            #     console.log 'SWITCH_STACK_TAB'
            #     model.setTabFlag(true)
            #     null

            #save
            view.on 'TOOLBAR_SAVE_CLICK', (data) ->
                console.log 'design_toolbar_click:saveStack'
                model.saveStack(data)

            #duplicate
            view.on 'TOOLBAR_DUPLICATE_CLICK', (new_name, data) ->
                console.log 'design_toolbar_click:duplicateStack'
                model.duplicateStack(new_name, data)

            #delete
            view.on 'TOOLBAR_DELETE_CLICK', (data) ->
                console.log 'design_toolbar_click:deleteStack'
                model.deleteStack(data)

            #run
            view.on 'TOOLBAR_RUN_CLICK', (app_name, data) ->
                console.log 'design_toolbar_click:runStack'
                model.runStack(app_name, data)

            #zoomin
            view.on 'TOOLBAR_ZOOMIN_CLICK', () ->
                console.log 'design_toolbar_click:zoomIn'
                model.zoomIn()

            #zoomout
            view.on 'TOOLBAR_ZOOMOUT_CLICK', () ->
                console.log 'design_toolbar_click:zoomOut'
                model.zoomOut()

            #export to png
            view.on 'TOOLBAR_EXPORT_PNG_CLICK', (data) ->
                console.log 'design_toolbar_click:exportPngIcon'
                model.savePNG false, data

            model.on 'SAVE_PNG_COMPLETE', ( base64_image ) ->
                console.log 'SAVE_PNG_COMPLETE'
                view.exportPNG base64_image

            ide_event.onLongListen 'SAVE_APP_THUMBNAIL', ( data ) ->
                console.log 'SAVE_APP_THUMBNAIL'
                model.savePNG true, data

            view.on 'TOOLBAR_STOP_CLICK', (data) ->
                console.log 'design_toolbar_click:stopApp'
                model.stopApp(data)

            view.on 'TOOLBAR_START_CLICK', (data) ->
                console.log 'design_toolbar_click:startApp'
                model.startApp(data)

            view.on 'TOOLBAR_TERMINATE_CLICK', (data) ->
                console.log 'design_toolbar_click:terminateApp'
                model.terminateApp(data)

            ide_event.onLongListen ide_event.CANVAS_SAVE, () ->
                console.log 'design_toolbar_click:saveStack'
                model.saveStack()

            model.on 'TOOLBAR_STACK_RUN_SUCCESS', (name) ->
                view.notify 'info', 'Run stack ' + name + ' successfully.'
            model.on 'TOOLBAR_STACK_RUN_FAILED', (name) ->
                view.notify 'error', 'Run stack ' + name + ' failed.'
            model.on 'TOOLBAR_STACK_RUN_REQUEST_SUCCESS', (name) ->
                view.notify 'info', 'Run stack ' + name + ' request successfully.'
            model.on 'TOOLBAR_STACK_RUN_REQUEST_FAILED', (name) ->
                view.notify 'error', 'Run stack ' + name + ' request failed.'

            model.on 'TOOLBAR_STACK_SAVE_SUCCESS', (name) ->
                view.notify 'info', 'Save stack ' + name + ' successfully.'
            model.on 'TOOLBAR_STACK_SAVE_FAILED', (name) ->
                view.notify 'error', 'Save stack ' + name + ' failed.'

            model.on 'TOOLBAR_STACK_DUPLICATE_SUCCESS', (name) ->
                view.notify 'info', 'Duplicate stack ' + name + ' successfully.'
            model.on 'TOOLBAR_STACK_DUPLICATE_FAILED', (name) ->
                view.notify 'error', 'Duplicate stack ' + name + ' failed.'

            model.on 'TOOLBAR_STACK_DELETE_SUCCESS', (name) ->
                view.notify 'info', 'Delete stack ' + name + ' successfully.'
            model.on 'TOOLBAR_STACK_DELETE_FAILED', (name) ->
                view.notify 'error', 'Delete stack ' + name + ' failed.'

            model.on 'TOOLBAR_APP_START_REQUEST_SUCCESS', (name) ->
                view.notify 'info', 'Start app ' + name + ' request successfully.'
            model.on 'TOOLBAR_APP_START_REQUEST_FAILED', (name) ->
                view.notify 'error', 'Start app ' +　name + ' request failed.'
            model.on 'TOOLBAR_APP_START_SUCCESS', (name) ->
                view.notify 'info', 'Start app ' + name + ' successfully.'
            model.on 'TOOLBAR_APP_START_FAILED', (name) ->
                view.notify 'error', 'Start app ' + name + ' failed.'

            model.on 'TOOLBAR_APP_STOP_REQUEST_SUCCESS', (name) ->
                view.notify 'info', 'Stop app ' + name + ' request successfully.'
            model.on 'TOOLBAR_APP_STOP_REQUEST_FAILED', (name) ->
                view.notify 'error', 'Stop app ' + name + ' request failed.'
            model.on 'TOOLBAR_APP_STOP_SUCCESS', (name) ->
                view.notify 'info', 'Stop app ' + name + ' successfully.'
            model.on 'TOOLBAR_APP_STOP_FAILED', (name) ->
                view.notify 'error', 'Stop app ' + name + ' successfully.'

            model.on 'TOOLBAR_APP_TERMINATE_REQUEST_SUCCESS', (name) ->
                view.notify 'info', 'Terminate app ' + name + ' request successfully.'
            model.on 'TOOLBAR_APP_TERMINATE_REQUEST_FAILED', (name) ->
                view.notify 'error', 'Terminate app ' + name + ' request failed.'
            model.on 'TOOLBAR_APP_TERMINATE_SUCCESS', (name) ->
                view.notify 'info', 'Terminate app ' + name + ' successfully.'
            model.on 'TOOLBAR_APP_TERMINATE_FAILED', (name) ->
                view.notify 'error', 'Terminate app ' + name + ' failed.'

    unLoadModule = () ->
        #view.remove()

    #public
    loadModule   : loadModule
    unLoadModule : unLoadModule