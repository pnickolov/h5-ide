#############################
#  View(UI logic) for design/toolbar
#############################

define [ 'MC', 'event',
         'backbone', 'jquery', 'handlebars'
         'UI.selectbox'
], ( MC, ide_event ) ->

    ToolbarView = Backbone.View.extend {

        el       : document

        template : Handlebars.compile $( '#toolbar-tmpl' ).html()

        events   :
            'click .icon-toolbar-run'           : 'clickRunIcon'
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

        clickRunIcon : ->
            target = $$( '#main-toolbar' )
            $('#btn-confirm').on 'click', { target : this }, (event) ->
                console.log 'clickRunIcon'
                event.data.target.trigger 'TOOLBAR_RUN_CLICK'
                modal.close()
            true

        clickSaveIcon : ->
            console.log 'clickSaveIcon'
            this.trigger 'TOOLBAR_SAVE_CLICK'

        clickDuplicateIcon : ->
            console.log 'clickDuplicateIcon'


            if not MC.canvas_data.id
                this.trigger 'TOOLBAR_SAVE_CLICK'

            this.trigger 'TOOLBAR_DUPLICATE_CLICK'

        clickDeleteIcon : ->
            target = $( '#main-toolbar' )
            $('#btn-confirm').on 'click', { target : this }, (event) ->
                console.log 'clickDeleteIcon'
                modal.close()
                event.data.target.trigger 'TOOLBAR_DELETE_CLICK'
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