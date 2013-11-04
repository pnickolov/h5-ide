####################################
#  Controller for design/toolbar module
####################################

define [ 'jquery',
         'event',
         'i18n!nls/lang.js'
], ( $, ide_event, lang ) ->

    #private
    loadModule = () ->

        require [ './module/design/toolbar/view', './module/design/toolbar/model' ], ( View, model ) ->

            #view
            view       = new View()
            view.model = model
            view.render()

            #listen OPEN_DESIGN
            ide_event.onLongListen ide_event.OPEN_DESIGN, ( region_name, type, current_platform, tab_name, tab_id ) ->
                console.log 'toolbar:OPEN_DESIGN, region_name = ' + region_name + ', type = ' + type
                console.log MC.canvas_data
                #
                model.setFlag tab_id, type

            ###
            #listen OPEN_TOOLBAR
            ide_event.onLongListen ide_event.OPEN_TOOLBAR, ( tab_id, type ) ->
                console.log 'toolbar:OPEN_TOOLBAR, tab_id = ' + tab_id + ', type = ' + type
                console.log MC.canvas_data
            ###

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
                console.log ide_event.SAVE_STACK

                try
                    #expand components
                    MC.canvas_data = MC.forge.stack.expandServerGroup MC.canvas_data
                    #save stack
                    model.saveStack MC.canvas.layout.save()
                    #compact and update canvas
                    MC.canvas_data = MC.forge.stack.compactServerGroup MC.canvas_data
                    #
                    MC.data.origin_canvas_data = $.extend true, {}, MC.canvas_data
                catch err
                    msg = sprintf lang.ide.TOOL_MSG_ERR_SAVE_FAILED, data.name
                    view.notify 'error', msg

                #model.saveStack(data)
                null

            #duplicate
            ide_event.onLongListen ide_event.DUPLICATE_STACK, (region, id, new_name, name) ->
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

            view.on 'UPDATE_APP', ( is_update ) ->
                model.updateApp is_update
                null

            #run
            view.on 'TOOLBAR_RUN_CLICK', (app_name, data) ->
                console.log 'design_toolbar_click:runStack'
                model.runStack(app_name, data)

            #export to png
            view.on 'TOOLBAR_EXPORT_PNG_CLICK', (data) ->
                console.log 'design_toolbar_click:exportPngIcon'
                model.savePNG false, data

            view.on 'CONVERT_CLOUDFORMATION', () ->
                model.convertCloudformation()

            model.on 'SAVE_PNG_COMPLETE', ( base64_image ) ->
                console.log 'SAVE_PNG_COMPLETE'
                view.exportPNG base64_image

            model.on 'CONVERT_CLOUDFORMATION_COMPLETE', ( cf_json ) ->
                view.saveCloudFormation cf_json

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

            ide_event.onLongListen 'TERMINATE_APP', (region, app_id, app_name, flag) ->
            #view.on 'TOOLBAR_TERMINATE_CLICK', (data) ->
                console.log 'design_toolbar TERMINATE_APP region:' + region + ', app_id:' + app_id + ', app_name:' + app_name + ', flag:' + flag
                model.terminateApp(region, app_id, app_name, flag)

            ide_event.onLongListen ide_event.SAVE_APP, (data) ->
                console.log 'design_toolbar SAVE_APP'

                data = MC.forge.stack.expandServerGroup data

                model.saveApp(data)

            ide_event.onLongListen ide_event.CANVAS_SAVE, () ->
                console.log 'design_toolbar_click:saveStack'
                model.saveStack()

            ide_event.onLongListen ide_event.UPDATE_REQUEST_ITEM, (idx, dag) ->
                console.log 'toolbar listen UPDATE_REQUEST_ITEM index:' + idx
                model.reqHandle idx, dag

            ide_event.onLongListen ide_event.APPEDIT_2_APP, ( tab_id, region ) ->
                console.log 'APPEDIT_2_APP, tab_id = ' + tab_id + ', region = ' + region
                view.saveSuccess2App tab_id, region

            model.on 'TOOLBAR_REQUEST_SUCCESS', (flag, name) ->

                if flag
                    str_idx = 'TOOLBAR_HANDLE_' + flag
                    if str_idx of lang.ide
                        msg = sprintf lang.ide.TOOL_MSG_INFO_REQ_SUCCESS, lang.ide[str_idx], name

                    else
                        info = flag.replace /_/g, ' '
                        msg = sprintf lang.ide.TOOL_MSG_INFO_REQ_SUCCESS, info.toLowerCase(), name

                    #view.notify 'info', 'Sending request to ' + info.toLowerCase() + ' ' + name + '...'
                    view.notify 'info', msg

            model.on 'TOOLBAR_REQUEST_FAILED', (flag, name) ->

                if flag
                    str_idx = 'TOOLBAR_HANDLE_' + flag
                    if str_idx of lang.ide
                        msg = sprintf lang.ide.TOOL_MSG_ERR_REQ_FAILED, lang.ide[str_idx], name

                    else
                        info = flag.replace /_/g, ' '
                        msg = sprintf lang.ide.TOOL_MSG_ERR_REQ_FAILED, info.toLowerCase(), name
                    #view.notify 'error', 'Sending request to ' + info.toLowerCase() + ' ' + name + ' failed.'
                    view.notify 'error', msg

            model.on 'TOOLBAR_HANDLE_SUCCESS', (flag, name) ->

                if flag
                    # run stack
                    if (flag == "SAVE_STACK" or flag == "CREATE_STACK") and modal and modal.isPopup()
                        app_name = $('.modal-input-value').val()
                        modal.close()

                        model.runStack app_name, MC.canvas_data
                        MC.data.app_list[MC.canvas_data.region].push app_name

                    str_idx = 'TOOLBAR_HANDLE_' + flag
                    if str_idx of lang.ide
                        msg = sprintf lang.ide.TOOL_MSG_INFO_HDL_SUCCESS, lang.ide[str_idx], name

                    else
                        info = flag.replace /_/g, ' '
                        info = info.toLowerCase()
                        info = info[0].toUpperCase() + info.substr(1)

                        msg = sprintf lang.ide.TOOL_MSG_INFO_HDL_SUCCESS, info, name
                    #view.notify 'info', info.toLowerCase() + ' ' + name + ' successfully.'
                    view.notify 'info', msg

            model.on 'TOOLBAR_HANDLE_FAILED', (flag, name) ->

                if flag

                    # run stack
                    if (flag == "SAVE_STACK" or flag == "CREATE_STACK") and modal and modal.isPopup()
                        app_name = $('.modal-input-value').val()
                        modal.close()

                    str_idx = 'TOOLBAR_HANDLE_' + flag
                    if str_idx of lang.ide
                        msg = sprintf lang.ide.TOOL_MSG_ERR_HDL_FAILED, lang.ide[str_idx], name

                    else
                        info = flag.replace /_/g, ' '
                        info = info.toLowerCase()
                        info = info[0].toUpperCase() + info.substr(1)

                        msg = sprintf lang.ide.TOOL_MSG_ERR_HDL_FAILED, info, name
                    #view.notify 'error', info.toLowerCase() + ' ' + name + ' failed.'
                    view.notify 'error', msg

    unLoadModule = () ->
        #view.remove()

    #public
    loadModule   : loadModule
    unLoadModule : unLoadModule
