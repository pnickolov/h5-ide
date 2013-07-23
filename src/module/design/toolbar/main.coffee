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
            ide_event.onLongListen ide_event.RELOAD_RESOURCE, ( region_name, type, current_paltform, item_name ) ->
                if type.search('APP') >= 0
                    console.log 'toolbar:RELOAD_RESOURCE, app name = ' + item_name + ', type = ' + type
                else
                    console.log 'toolbar:RELOAD_RESOURCE, stack name = ' + item_name + ', type = ' + type

                #
                model.setFlag type
                #
                #view.render type

            #listen toolbar state change
            model.on 'UPDATE_TOOLBAR', (type) ->
                console.log 'update toolbar status'
                view.render type

            #save
            view.on 'TOOLBAR_SAVE_CLICK', () ->
                console.log 'design_toolbar_click:saveStack'
                model.saveStack()

            #duplicate
            view.on 'TOOLBAR_DUPLICATE_CLICK', (new_name) ->
                console.log 'design_toolbar_click:duplicateStack'
                model.duplicateStack(new_name)

            #delete
            view.on 'TOOLBAR_DELETE_CLICK', () ->
                console.log 'design_toolbar_click:deleteStack'
                model.deleteStack()

            #run
            view.on 'TOOLBAR_RUN_CLICK', (app_name) ->
                console.log 'design_toolbar_click:runStack'
                model.runStack(app_name)

            #zoomin
            view.on 'TOOLBAR_ZOOMIN_CLICK', () ->
                console.log 'design_toolbar_click:zoomIn'
                model.zoomIn()

            #zoomout
            view.on 'TOOLBAR_ZOOMOUT_CLICK', () ->
                console.log 'design_toolbar_click:zoomOut'
                model.zoomOut()

            #export to png
            view.on 'TOOLBAR_EXPORT_PNG_CLICK', () ->
                console.log 'design_toolbar_click:exportPngIcon'
                model.savePNG false

            #
            model.on 'SAVE_PNG_COMPLETE', ( base64_image ) ->
                console.log 'SAVE_PNG_COMPLETE'
                view.exportPNG base64_image

            model.once 'TOOLBAR_STACK_RUN_SUCCESS', () ->
                view.notify 'info', 'Run stack ' + MC.canvas_data.name + ' successfully.'
            model.once 'TOOLBAR_STACK_RUN_FAILED', () ->
                view.notify 'error', 'Run stack ' + MC.canvas_data.name + ' failed.'
            model.once 'TOOLBAR_STACK_RUN_REQUEST_SUCCESS', () ->
                view.notify 'info', 'Run stack ' + MC.canvas_data.name + ' request successfully.'
            model.once 'TOOLBAR_STACK_RUN_REQUEST_ERROR', () ->
                view.notify 'error', 'Run stack ' + MC.canvas_data.name + ' request failed.'

            model.once 'TOOLBAR_STACK_SAVE_SUCCESS', () ->
                view.notify 'info', 'Save stack ' + name + ' successfully.'
            model.once 'TOOLBAR_STACK_SAVE_ERROR', () ->
                view.notify 'error', 'Save stack ' + name + ' failed.'

            model.once 'TOOLBAR_STACK_DUPLICATE_SUCCESS', () ->
                view.notify 'info', 'Duplicate stack ' + name + ' successfully.'
            model.once 'TOOLBAR_STACK_DUPLICATE_ERROR', () ->
                view.notify 'error', 'Duplicate stack ' + name + ' failed.'

            model.once 'TOOLBAR_STACK_DELETE_SUCCESS', () ->
                view.notify 'info', 'Delete stack ' + MC.canvas_data.name + ' successfully.'
            model.once 'TOOLBAR_STACK_DELETE_ERROR', () ->
                view.notify 'error', 'Delete stack ' + MC.canvas_data.name + ' failed.'

    unLoadModule = () ->
        #view.remove()

    #public
    loadModule   : loadModule
    unLoadModule : unLoadModule