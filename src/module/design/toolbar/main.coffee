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

            #save
            ide_event.onLongListen ide_event.SAVE_STACK, (data) ->
            #view.on 'TOOLBAR_SAVE_CLICK', (data) ->
                console.log ide_event.SAVE_STACK
                model.saveStack(data)

            #duplicate
            ide_event.onLongListen ide_event.DUPLICATE_STACK, (region, id, new_name, name) ->
            #view.on 'TOOLBAR_DUPLICATE_CLICK', (new_name, data) ->
                console.log ide_event.DUPLICATE_STACK + ':' + region + ',' + id + ',' + new_name + ',' + name
                model.duplicateStack(region, id, new_name, name)

            #delete
            ide_event.onLongListen ide_event.DELETE_STACK, (region, id, name) ->
            #view.on 'TOOLBAR_DELETE_CLICK', (data) ->
                console.log ide_event.DELETE_STACK + ':' + region + ',' + id + ',' + name
                model.deleteStack(region, id, name)

            #zoomin
            view.on 'TOOLBAR_ZOOM_IN', () ->
                console.log 'TOOLBAR_ZOOM_IN'
                model.zoomIn()

            #zoomout
            view.on 'TOOLBAR_ZOOM_OUT', () ->
                console.log 'TOOLBAR_ZOOM_OUT'
                model.zoomOut()

            #run
            view.on 'TOOLBAR_RUN_CLICK', (app_name, data) ->
                console.log 'design_toolbar_click:runStack'
                model.runStack(app_name, data)

            #export to png
            view.on 'TOOLBAR_EXPORT_PNG_CLICK', (data) ->
                console.log 'design_toolbar_click:exportPngIcon'
                model.savePNG false, data

            model.on 'SAVE_PNG_COMPLETE', ( base64_image ) ->
                console.log 'SAVE_PNG_COMPLETE'
                view.exportPNG base64_image

            ide_event.onLongListen 'SAVE_APP_THUMBNAIL', ( region, app_name, app_id ) ->
                console.log 'SAVE_APP_THUMBNAIL region:' + region + ' app_name:' + app_name
                model.saveAppThumbnail(region, app_name, app_id)

            # app operation
            ide_event.onLongListen 'STOP_APP', (region, app_id, app_name) ->
            #view.on 'TOOLBAR_STOP_CLICK', (data) ->
                console.log 'design_toolbar STOP_APP region:' + region + ', app_id:' + app_id + ', app_name:' + app_name
                model.stopApp(region, app_id, app_name)

            ide_event.onLongListen 'START_APP', (region, app_id, app_name) ->
            #view.on 'TOOLBAR_START_CLICK', (data) ->
                console.log 'design_toolbar START_APP region:' + region + ', app_id:' + app_id + ', app_name:' + app_name
                model.startApp(region, app_id, app_name)

            ide_event.onLongListen 'TERMINATE_APP', (region, app_id, app_name) ->
            #view.on 'TOOLBAR_TERMINATE_CLICK', (data) ->
                console.log 'design_toolbar TERMINATE_APP region:' + region + ', app_id:' + app_id + ', app_name:' + app_name
                model.terminateApp(region, app_id, app_name)

            ide_event.onLongListen ide_event.CANVAS_SAVE, () ->
                console.log 'design_toolbar_click:saveStack'
                model.saveStack()

            model.on 'TOOLBAR_REQUEST_SUCCESS', (flag, name) ->
                    info = flag.replace /_/g, ' '
                    if info
                        view.notify 'info', 'Sending request to ' + info.toLowerCase() + ' ' + name + ' successfully.'

            model.on 'TOOLBAR_REQUEST_FAILED', (flag, name) ->
                info = flag.replace /_/g, ' '
                if info
                    view.notify 'error', 'Sending request to ' + info.toLowerCase() + ' ' + name + ' failed.'

            model.on 'TOOLBAR_HANDLE_SUCCESS', (flag, name) ->
                info = flag.replace /_/g, ' '
                if info
                    view.notify 'info', info.toLowerCase() + ' ' + name + ' successfully.'

            model.on 'TOOLBAR_HANDLE_FAILED', (flag, name) ->
                info = flag.replace /_/g, ' '
                if info
                    view.notify 'error', info.toLowerCase() + ' ' + name + ' failed.'


    unLoadModule = () ->
        #view.remove()

    #public
    loadModule   : loadModule
    unLoadModule : unLoadModule