#############################
#  View(UI logic) for design/toolbar
#############################

define [ 'MC', 'event',
         'backbone', 'jquery', 'handlebars'
         'UI.selectbox'
], ( MC, ide_event ) ->

    ToolbarView = Backbone.View.extend {

        el       : $( '#main-toolbar' )

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
            #'click #toolbar-export-json'        : 'clickExportJSONIcon'

        render   : () ->
            console.log 'toolbar render'
            $( '#main-toolbar' ).html this.template

        clickRunIcon : ->
            console.log 'clickRunIcon'
            this.trigger 'TOOLBAR_RUN_CLICK'

        clickSaveIcon : ->
            console.log 'clickSaveIcon'
            this.trigger 'TOOLBAR_SAVE_CLICK'

        clickDuplicateIcon : ->
            console.log 'clickDuplicateIcon'
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
            this.trigger 'TOOLBAR_NEW_CLICK'

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

        clickExportPngIcon : ->
            console.log 'clickExportPngIcon'
            this.trigger 'TOOLBAR_EXPORT_PNG_CLICK'

        clickExportJSONIcon : ->
            console.log 'clickExportJSONIcon'
            this.trigger 'TOOLBAR_EXPORT_JSON_CLICK'

    }

    return ToolbarView