#############################
#  View(UI logic) for design/toolbar
#############################

define [ 'MC', 'event',
         'zeroclipboard',
         'backbone', 'jquery', 'handlebars',
         'UI.selectbox', 'UI.notification', 'UI.zeroclipboard'
], ( MC, ide_event, ZeroClipboard ) ->

    ToolbarView = Backbone.View.extend {

        el       : document

        stack_tmpl : Handlebars.compile $( '#toolbar-stack-tmpl' ).html()
        app_tmpl : Handlebars.compile $( '#toolbar-app-tmpl' ).html()

        events   :
            'click #toolbar-run'                : 'clickRunIcon'
            'click .icon-toolbar-save'          : 'clickSaveIcon'
            'click #toolbar-duplicate'          : 'clickDuplicateIcon'
            'click #toolbar-delete'             : 'clickDeleteIcon'
            'click #toolbar-new'                : 'clickNewStackIcon'
            'click .icon-toolbar-zoom-in'       : 'clickZoomInIcon'
            'click .icon-toolbar-zoom-out'      : 'clickZoomOutIcon'
            'click .icon-toolbar-undo'          : 'clickUndoIcon'
            'click .icon-toolbar-redo'          : 'clickRedoIcon'
            'click #toolbar-export-png'         : 'clickExportPngIcon'
            'click #toolbar-export-json'        : 'clickExportJSONIcon'
            'click #toolbar-stop-app'           : 'clickStopApp'
            'click #toolbar-start-app'          : 'clickStartApp'
            'click #toolbar-terminate-app'      : 'clickTerminateApp'
            #for debug
            'click #toolbar-jsondiff'           : 'clickOpenJSONDiff'
            'click #toolbar-jsonview'           : 'clickOpenJSONView'

        render   : ( type ) ->
            console.log 'toolbar render'
            #
            if type is 'app'
                $( '#main-toolbar' ).html this.app_tmpl this.model.attributes
            else
                $( '#main-toolbar' ).html this.stack_tmpl this.model.attributes
            #
            ide_event.trigger ide_event.DESIGN_SUB_COMPLETE
            #
            zeroclipboard.init 'toolbar-jsoncopy', ZeroClipboard

        reRender   : ( type ) ->
            console.log 're-toolbar render'
            if $.trim( $( '#main-toolbar' ).html() ) is 'loading...'
                #
                if type is 'stack'
                    $( '#main-toolbar' ).html this.stack_tmpl this.model.attributes
                else
                    $( '#main-toolbar' ).html this.app_tmpl this.model.attributes

        clickRunIcon : ->
            me = this

            target = $( '#main-toolbar' )
            $('#btn-confirm').on 'click', { target : this }, (event) ->
                console.log 'clickRunIcon'

                app_name = $('.modal-input-value').val()

                #check app name
                if not app_name
                    notification 'error', 'No app name.'
                    return
                if app_name in MC.data.app_list[MC.canvas_data.region]
                    notification 'error', 'Repeated app name.'
                    return

                me.trigger 'TOOLBAR_RUN_CLICK', app_name
                modal.close()

                MC.data.app_list[MC.canvas_data.region].push app_name

            true

        clickSaveIcon : ->
            console.log 'clickSaveIcon'

            name = MC.canvas_data.name

            if not name
                notification 'error', 'No stack name.'
            else if name.slice(0, 8) == 'untitled'
                notification 'error', 'Please modify the initial stack name'
            else if not MC.canvas_data.id and name in MC.data.stack_list[MC.canvas_data.region]
                notification 'error', 'Repeated stack name'
            else
                this.trigger 'TOOLBAR_SAVE_CLICK'

            true

        clickDuplicateIcon : ->
            console.log 'clickDuplicateIcon'

            name     = MC.canvas_data.name
            new_name = name + '-copy'

            #check name
            if this.model.attributes.is_duplicate
                if not name
                    notification 'error', 'No stack name.'
                else if new_name in MC.data.stack_list[MC.canvas_data.region]
                    notification 'error', 'Repeated stack name.'
                else
                    this.trigger 'TOOLBAR_DUPLICATE_CLICK', new_name

            true

        clickDeleteIcon : ->
            me = this

            if this.model.attributes.is_delete
                target = $( '#main-toolbar' )
                $('#btn-confirm').on 'click', { target : this }, (event) ->
                    console.log 'clickDeleteIcon'
                    modal.close()

                    me.trigger 'TOOLBAR_DELETE_CLICK'

            true

        clickNewStackIcon : ->
            console.log 'clickNewStackIcon'
            ide_event.trigger ide_event.ADD_STACK_TAB, MC.canvas_data.region

        clickZoomInIcon : ->
            console.log 'clickZoomInIcon'

            if this.model.attributes.is_zoomin
                this.trigger 'TOOLBAR_ZOOMIN_CLICK'
            else
                notification 'warning', 'Cannot zoom in now.'

        clickZoomOutIcon : ->
            console.log 'clickZoomOutIcon'

            if this.model.attributes.is_zoomout
                this.trigger 'TOOLBAR_ZOOMOUT_CLICK'
            else
                notification 'warning', 'Cannot zoom out now.'

        clickUndoIcon : ->
            console.log 'clickUndoIcon'
            #temp
            require [ 'component/stackrun/main' ], ( stackrun_main ) ->
                stackrun_main.loadModule()

        clickRedoIcon : ->
            console.log 'clickRedoIcon'
            #temp
            require [ 'component/sgrule/main' ], ( sgrule_main ) ->
                sgrule_main.loadModule()

        clickExportPngIcon : ->
            console.log 'clickExportPngIcon'
            this.trigger 'TOOLBAR_EXPORT_PNG_CLICK'

        clickExportJSONIcon : ->
            file_content = MC.canvas.layout.save()
            #this.trigger 'TOOLBAR_EXPORT_MENU_CLICK'
            $( '#btn-confirm' ).attr {
                'href'      : "data://text/plain; " + file_content,
                'download'  : MC.canvas_data.name + '.json',
            }
            $( '#json-content' ).val file_content

            $('#btn-confirm').on 'click', { target : this }, (event) ->
                    console.log 'clickExportJSONIcon'
                    modal.close()

        exportPNG : ( base64_image ) ->
            console.log 'exportPNG'
            #$( 'body' ).html '<img src="data:image/png;base64,' + base64_image + '" />'
            modal MC.template.exportpng {"title":"Export PNG", "confirm":"Download", "color":"blue" }, true
            $( '.modal-body' ).html '<img src="data:image/png;base64,' + base64_image + '" />'
            $( '#btn-confirm' ).attr {
                'href'      : "data:image/png;base64, " + base64_image,
                'download'  : MC.canvas_data.name + '.png',
            }
            $('#btn-confirm').one 'click', { target : this }, () -> modal.close()

        #for debug
        clickOpenJSONDiff : ->
            #
            a = MC.canvas_property.original_json.split('"').join('\\"')
            b = JSON.stringify(MC.canvas_data).split('"').join('\\"')
            param = '{"d":{"a":"'+a+'","b":"'+b+'"}}'
            #
            window.open 'test/jsondiff/jsondiff.htm#' + encodeURIComponent(param)
            null

        clickOpenJSONView : ->
            window.open 'http://jsonviewer.stack.hu/'
            null

        notify : (type, msg) ->
            notification type, msg

        clickStopApp : (event) ->
            me = this
            console.log 'click stop app'

            if not me.model.attributes.is_pending
                target = $( '#main-toolbar' )
                $('#btn-confirm').on 'click', { target : this }, (event) ->
                    me.trigger 'TOOLBAR_STOP_CLICK'
                    modal.close()
            else
                notification 'warning', me.model.attributes.item_type + ' ' + MC.canvas_data.name + ' is pending.'

        clickStartApp : (event) ->
            me = this
            console.log 'click run app'

            if not me.model.attributes.is_pending
                target = $( '#main-toolbar' )
                $('#btn-confirm').on 'click', { target : this }, (event) ->
                    me.trigger 'TOOLBAR_START_CLICK'
                    modal.close()
            else
                notification 'warning', me.model.attributes.item_type + ' ' + MC.canvas_data.name + ' is pending.'

        clickTerminateApp : (event) ->
            me = this

            console.log 'click terminate app'

            if not me.model.attributes.is_pending
                target = $( '#main-toolbar' )
                $('#btn-confirm').on 'click', { target : this }, (event) ->
                    me.trigger 'TOOLBAR_TERMINATE_CLICK'
                    modal.close()
            else
                notification 'warning', me.model.attributes.item_type + ' ' + MC.canvas_data.name + ' is pending.'

    }

    return ToolbarView

