#############################
#  View(UI logic) for design/toolbar
#############################

define [ 'MC', 'event',
         'backbone', 'jquery', 'handlebars',
         'UI.selectbox', 'UI.notification'
], ( MC, ide_event ) ->

    ToolbarView = Backbone.View.extend {

        el       : document

        template : Handlebars.compile $( '#toolbar-tmpl' ).html()

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
            #for debug
            'click #toolbar-jsondiff'           : 'clickOpenJSONDiff'
            'click #toolbar-jsonview'           : 'clickOpenJSONView'


        render   : () ->
            console.log 'toolbar render'
            $( '#main-toolbar' ).html this.template
            ide_event.trigger ide_event.DESIGN_SUB_COMPLETE



        reRender   : ( template ) ->
            console.log 're-toolbar render'
            #if $.trim( $( '#main-toolbar' ).html() ) is 'loading...' then $( '#main-toolbar' ).html this.template
            $( '#main-toolbar' ).html this.template this.model.attributes

            this.initZeroClipboard()


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

                me.model.once 'TOOLBAR_STACK_RUN_SUCCESS', () ->
                    notification 'info', 'Run stack ' + MC.canvas_data.name + ' successfully.'
                me.model.once 'TOOLBAR_STACK_RUN_FAILED', () ->
                    notification 'error', 'Run stack ' + MC.canvas_data.name + ' failed.'
                me.model.once 'TOOLBAR_STACK_RUN_REQUEST_SUCCESS', () ->
                    notification 'info', 'Run stack ' + MC.canvas_data.name + ' request successfully.'
                me.model.once 'TOOLBAR_STACK_RUN_REQUEST_ERROR', () ->
                    notification 'error', 'Run stack ' + MC.canvas_data.name + ' request failed.'
            true

        clickSaveIcon : ->
            console.log 'clickSaveIcon'

            name = MC.canvas_data.name

            if not name
                notification 'error', 'No stack name.'
            else if name.slice(0, 7) == 'untitled'
                notification 'error', 'Please modify the initial stack name'
            else if not MC.canvas_data.id and name in MC.data.stack_list[MC.canvas_data.region]
                notification 'error', 'Repeated stack name'
            else
                this.trigger 'TOOLBAR_SAVE_CLICK'

                this.model.once 'TOOLBAR_STACK_SAVE_SUCCESS', () ->
                    notification 'info', 'Save stack ' + name + ' successfully.'
                this.model.once 'TOOLBAR_STACK_SAVE_ERROR', () ->
                    notification 'error', 'Save stack ' + name + ' failed.'

        clickDuplicateIcon : ->
            console.log 'clickDuplicateIcon'

            name     = MC.canvas_data.name
            new_name = name + '-copy'
            #check name
            if not name
                notification 'error', 'No stack name.'
            else if new_name in MC.data.stack_list[MC.canvas_data.region]
                notification 'error', 'Repeated stack name.'
            else
                this.trigger 'TOOLBAR_DUPLICATE_CLICK', new_name

                this.model.once 'TOOLBAR_STACK_DUPLICATE_SUCCESS', () ->
                    notification 'info', 'Duplicate stack ' + name + ' successfully.'
                this.model.once 'TOOLBAR_STACK_DUPLICATE_ERROR', () ->
                    notification 'error', 'Duplicate stack ' + name + ' failed.'

            true

        clickDeleteIcon : ->
            me = this

            target = $( '#main-toolbar' )
            $('#btn-confirm').on 'click', { target : this }, (event) ->
                console.log 'clickDeleteIcon'
                modal.close()

                me.trigger 'TOOLBAR_DELETE_CLICK'

                me.model.once 'TOOLBAR_STACK_DELETE_SUCCESS', () ->
                    notification 'info', 'Delete stack ' + MC.canvas_data.name + ' successfully.'
                me.model.once 'TOOLBAR_STACK_DELETE_ERROR', () ->
                    notification 'error', 'Delete stack ' + MC.canvas_data.name + ' failed.'
            true

        clickNewStackIcon : ->
            console.log 'clickNewStackIcon'
            ide_event.trigger ide_event.ADD_STACK_TAB, MC.canvas_data.region

        clickZoomInIcon : ->
            console.log 'clickZoomInIcon'
            this.trigger 'TOOLBAR_ZOOMIN_CLICK'

        clickZoomOutIcon : ->
            console.log 'clickZoomOutIcon'
            this.trigger 'TOOLBAR_ZOOMOUT_CLICK'

        clickUndoIcon : ->
            console.log 'clickUndoIcon'

        clickRedoIcon : ->
            console.log 'clickRedoIcon'
            #
            this.model.savePNG()

        clickExportPngIcon : ->
            console.log 'clickExportPngIcon'
            this.trigger 'TOOLBAR_EXPORT_PNG_CLICK'

        clickExportJSONIcon : ->
            file_content = MC.canvas.layout.save()
            this.trigger 'TOOLBAR_EXPORT_MENU_CLICK'
            $( '#btn-confirm' ).attr {
                'href'      : "data://text/plain; " + file_content,
                'download'  : MC.canvas_data.name + '.json',
            }
            $( '#json-content' ).val file_content


        #for debug

        clickOpenJSONDiff : ->

            a = MC.canvas_property.original_json.split('"').join('\\"')
            b = JSON.stringify(MC.canvas_data).split('"').join('\\"')
            param = '{"d":{"a":"'+a+'","b":"'+b+'"}}'

            window.open 'test/jsondiff/jsondiff.htm#' + encodeURIComponent(param)
            null

        initZeroClipboard : () ->

            window.zeroClipboardInit( 'toolbar-jsoncopy' )

            null

        clickOpenJSONView : ->

            window.open 'http://jsonviewer.stack.hu/'
            null

        exportPNG : ( base64_image ) ->
            console.log 'exportPNG'
            #$( 'body' ).html '<img src="data:image/png;base64,' + base64_image + '" />'

    }

    return ToolbarView
