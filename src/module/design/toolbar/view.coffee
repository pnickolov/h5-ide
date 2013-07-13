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
            'click #toolbar-new-stack'          : 'clickNewStackIcon'
            'click .icon-toolbar-zoom-in'       : 'clickZoomInIcon'
            'click .icon-toolbar-zoom-out'      : 'clickZoomOutIcon'
            'click .icon-toolbar-undo'          : 'clickUndoIcon'
            'click .icon-toolbar-redo'          : 'clickRedoIcon'
            'click #toolbar-export-png'         : 'clickExportPngIcon'
            'click #toolbar-export-json'        : 'clickExportJSONIcon'
            'click .icon-toolbar-export'        : 'clickExportMenu'

        render   : () ->
            console.log 'toolbar render'
            $( '#main-toolbar' ).html this.template
            #
            ide_event.trigger ide_event.DESIGN_SUB_COMPLETE

        reRender   : ( template ) ->
            console.log 're-toolbar render'
            if $.trim( $( '#main-toolbar' ).html() ) is 'loading...' then $( '#main-toolbar' ).html this.template

        clickRunIcon : ->
            me = this

            target = $( '#main-toolbar' )
            $('#btn-confirm').on 'click', { target : this }, (event) ->
                console.log 'clickRunIcon'
                me.trigger 'TOOLBAR_RUN_CLICK'
                modal.close()

                me.model.once 'TOOLBAR_STACK_RUN_SUCCESS', () ->
                    notification 'info', 'Run stack ' + MC.canvas_data.name + ' successfully', true
                me.model.once 'TOOLBAR_STACK_RUN_ERROR', () ->
                    notification 'error', 'Run stack ' + MC.canvas_data.name + ' failed', true
            true

        clickSaveIcon : ->
            console.log 'clickSaveIcon'

            name = MC.canvas_data.name

            if not name
                notification('error', 'No stack name', true)
            else
                this.trigger 'TOOLBAR_SAVE_CLICK'

                this.model.once 'TOOLBAR_STACK_SAVE_SUCCESS', () ->
                    notification 'info', 'Save stack ' + name + ' successfully', true
                this.model.once 'TOOLBAR_STACK_SAVE_ERROR', () ->
                    notification 'error', 'Save stack ' + name + ' failed', true

        clickDuplicateIcon : ->
            console.log 'clickDuplicateIcon'

            name     = MC.canvas_data.name
            new_name = name + '-copy'
            #check name
            if not name
                notification('error', 'No stack name', true)
            else if new_name in MC.data.stack_list[MC.canvas_data.region]
                notification('error', 'Repeated stack name', true)
            else
                ori_data = MC.canvas_property.original_json
                new_data = JSON.stringify( MC.canvas_data )

                if not MC.canvas_data.id or ori_data != new_data
                    notification('info', 'Please save stack first', true)
                else
                    this.trigger 'TOOLBAR_DUPLICATE_CLICK', new_name

                    this.model.once 'TOOLBAR_STACK_DUPLICATE_SUCCESS', () ->
                        notification 'info', 'Duplicate stack ' + name + ' successfully', true
                    this.model.once 'TOOLBAR_STACK_DUPLICATE_ERROR', () ->
                        notification 'error', 'Duplicate stack ' + name + ' failed', true

        clickDeleteIcon : ->
            me = this

            target = $( '#main-toolbar' )
            $('#btn-confirm').on 'click', { target : this }, (event) ->
                console.log 'clickDeleteIcon'
                modal.close()
                me.trigger 'TOOLBAR_DELETE_CLICK'

                me.model.once 'TOOLBAR_STACK_DELETE_SUCCESS', () ->
                    notification 'info', 'Delete stack ' + MC.canvas_data.name + ' successfully'
                me.model.once 'TOOLBAR_STACK_DELETE_ERROR', () ->
                    notification 'error', 'Delete stack ' + MC.canvas_data.name + ' failed'
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

    }

    return ToolbarView