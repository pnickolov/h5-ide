#############################
#  View(UI logic) for design/toolbar
#############################

define [ 'event',
         'backbone', 'jquery', 'handlebars'
         'UI.selectbox'
], ( ide_event ) ->

    ToolbarView = Backbone.View.extend {

        el       : $ document

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
            'click .icon-toolbar-export-png'    : 'clickExportPngIcon'
            'click .icon-toolbar-export-json'   : 'clickExportJSONIcon'

        render   : ( template ) ->
            console.log 'toolbar render'
            $( '#main-toolbar' ).html template

        clickRunIcon : ->
            console.log 'clickRunIcon'
            this.trigger 'TOOLBAR_RUN_STACK_CLICK'

        clickSaveIcon : ->
            console.log 'clickSaveIcon'
            this.trigger 'TOOLBAR_SAVE_STACK_CLICK'

        clickDuplicateIcon : ->
            console.log 'clickDuplicateIcon'
            this.trigger 'TOOLBAR_DUPLICATE_STACK_CLICK'

        clickDeleteIcon : ->
            console.log 'clickDeleteIcon'

            this.trigger 'TOOLBAR_DELETE_STACK_CLICK'

        clickNewStackIcon : ->
            console.log 'clickNewStackIcon'

            this.trigger 'TOOLBAR_NEW_STACK_CLICK'

        clickZoomInIcon : ->
            console.log 'clickZoomInIcon'

        clickZoomOutIcon : ->
            console.log 'clickZoomOutIcon'

        clickUndoIcon : ->
            console.log 'clickUndoIcon'

        clickRedoIcon : ->
            console.log 'clickRedoIcon'

        clickExportPngIcon : ->
            console.log 'clickExportPngIcon'

        clickExportJSONIcon : ->
            console.log 'clickExportJSONIcon'

    }

    return ToolbarView