#############################
#  View(UI logic) for design/toolbar
#############################

define [ 'event',
         'backbone', 'jquery', 'handlebars'
         'UI.selectbox'
], ( event ) ->

    ToolbarView = Backbone.View.extend {

        el       : $ document

        events   :
            'click .icon-toolbar-save'        : 'clickSaveIcon'
            'click .icon-toolbar-duplicate'   : 'clickDuplicateIcon'
            'click .icon-toolbar-delete'      : 'clickDeleteIcon'
            'click .icon-toolbar-new-stack'   : 'clickNewStackIcon'
            'click .icon-toolbar-zoom-in'     : 'clickZoomInIcon'
            'click .icon-toolbar-zoom-out'    : 'clickZoomOutIcon'
            'click .icon-toolbar-undo'        : 'clickUndoIcon'
            'click .icon-toolbar-redo'        : 'clickRedoIcon'
            'click .icon-toolbar-export-png'  : 'clickExportPngIcon'
            'click .icon-toolbar-export-json' : 'clickExportJSONIcon'

        render   : ( template ) ->
            console.log 'toolbar render'
            $( '#main-toolbar' ).html template

        clickSaveIcon : ->
            console.log 'clickSaveIcon'

        clickDuplicateIcon : ->
            console.log 'clickDuplicateIcon'

        clickDeleteIcon : ->
            console.log 'clickDeleteIcon'

        clickNewStackIcon : ->
            console.log 'clickNewStackIcon'

        clickZoomInIcon : ->
            console.log 'clickZoomInIcon'

        clickZoomOutIcon : ->
            console.log 'clickZoomOutIcon'

        clickUndoIcon : ->
            console.log 'clickUndoIcon'

        clickRedoIcon : ->
            console.log 'clickRedoIcon'
            #
            this.model.savePNG()

        clickExportPngIcon : ->
            console.log 'clickExportPngIcon'

        clickExportJSONIcon : ->
            console.log 'clickExportJSONIcon'

    }

    return ToolbarView