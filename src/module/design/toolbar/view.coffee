#############################
#  View(UI logic) for design/toolbar
#############################

define [ 'MC', 'event',
         'zeroclipboard', 'i18n!/nls/lang.js',
         'backbone', 'jquery', 'handlebars',
         'UI.selectbox', 'UI.notification', 'UI.zeroclipboard'
], ( MC, ide_event, ZeroClipboard, lang ) ->

    ToolbarView = Backbone.View.extend {

        el       : document

        stack_tmpl : Handlebars.compile $( '#toolbar-stack-tmpl' ).html()
        app_tmpl : Handlebars.compile $( '#toolbar-app-tmpl' ).html()

        events   :
            'click #toolbar-run'           : 'clickRunIcon'
            'click .icon-save'             : 'clickSaveIcon'
            'click #toolbar-duplicate'     : 'clickDuplicateIcon'
            'click #toolbar-delete'        : 'clickDeleteIcon'
            'click #toolbar-new'           : 'clickNewStackIcon'
            'click .icon-zoom-in'          : 'clickZoomInIcon'
            'click .icon-zoom-out'         : 'clickZoomOutIcon'
            'click .icon-undo'             : 'clickUndoIcon'
            'click .icon-redo'             : 'clickRedoIcon'
            'click #toolbar-export-png'    : 'clickExportPngIcon'
            'click #toolbar-export-json'   : 'clickExportJSONIcon'
            'click #toolbar-stop-app'      : 'clickStopApp'
            'click #toolbar-start-app'     : 'clickStartApp'
            'click #toolbar-terminate-app' : 'clickTerminateApp'
            #for debug
            'click #toolbar-jsondiff' : 'clickOpenJSONDiff'
            'click #toolbar-jsonview' : 'clickOpenJSONView'

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
                    notification 'warning', lang.ide.PROP_MSG_WARN_NO_APP_NAME
                    return
                if app_name in MC.data.app_list[MC.canvas_data.region]
                    notification 'warning', lang.ide.PROP_MSG_WARN_REPEATED_APP_NAME
                    return

                me.trigger 'TOOLBAR_RUN_CLICK', app_name, MC.canvas_data
                modal.close()

                MC.data.app_list[MC.canvas_data.region].push app_name

            true

        clickSaveIcon : ->
            console.log 'clickSaveIcon'

            name = MC.canvas_data.name

            if not name
                notification 'warning', lang.ide.PROP_MSG_WARN_NO_STACK_NAME
            else if name.indexOf(' ') >= 0
                notification 'warning', 'stack name contains white space.'
            else if not MC.canvas_data.id and name in MC.data.stack_list[MC.canvas_data.region]
                notification 'warning', lang.ide.PROP_MSG_WARN_REPEATED_STACK_NAME
            else
                MC.canvas_data.name = name
                ide_event.trigger ide_event.SAVE_STACK, MC.canvas_data

            true

        clickDuplicateIcon : ->
            name     = MC.canvas_data.name

            doDuplicate = ( name ) =>
                new_name = "#{name}-copy"
                #check name
                if not name
                    notification 'warning', lang.ide.PROP_MSG_WARN_NO_STACK_NAME
                else if name.indexOf(' ') >= 0
                    notification 'warning', 'stack name contains white space.'
                else if new_name in MC.data.stack_list[MC.canvas_data.region]
                    notification 'warning', lang.ide.PROP_MSG_WARN_REPEATED_STACK_NAME
                else if not MC.aws.aws.checkStackName null, new_name
                    doDuplicate( new_name )
                    #notification 'warning', 'Repeated stack name.'
                else
                    # save stack
                    ide_event.trigger ide_event.SAVE_STACK, MC.canvas_data

                    setTimeout () ->
                        ide_event.trigger ide_event.DUPLICATE_STACK, MC.canvas_data.region, MC.canvas_data.id, new_name, MC.canvas_data.name
                    , 500

            doDuplicate name

            true

        clickDeleteIcon : ->
            me = this

            target = $( '#main-toolbar' )
            $('#btn-confirm').on 'click', { target : this }, (event) ->
                console.log 'clickDeleteIcon'
                modal.close()

                ide_event.trigger ide_event.DELETE_STACK, MC.canvas_data.region, MC.canvas_data.id, MC.canvas_data.name

        clickNewStackIcon : ->
            console.log 'clickNewStackIcon'
            ide_event.trigger ide_event.ADD_STACK_TAB, MC.canvas_data.region

        clickZoomInIcon : ( event ) ->
            console.log 'clickZoomInIcon'

            if $( event.currentTarget ).hasClass("disabled")
                return false

            # if MC.canvas_property.SCALE_RATIO > 1
            #     MC.canvas.zoomIn()

            # $("#main-toolbar .icon-zoom-out").toggleClass("disabled", false)

            # if MC.canvas_property.SCALE_RATIO <= 1
            #     $("#main-toolbar .icon-zoom-in").toggleClass("disabled", true)

            # return false

            this.trigger 'TOOLBAR_ZOOM_IN'


        clickZoomOutIcon : ( event )->
            console.log 'clickZoomOutIcon'

            if $( event.currentTarget ).hasClass("disabled")
                return false

            # if MC.canvas_property.SCALE_RATIO < 1.6
            #     MC.canvas.zoomOut()

            # $("#main-toolbar .icon-zoom-in").toggleClass("disabled", false)

            # if MC.canvas_property.SCALE_RATIO >= 1.6
            #     $("#main-toolbar .icon-zoom-out").toggleClass("disabled", true)

            # return false

            this.trigger 'TOOLBAR_ZOOM_OUT'

        clickUndoIcon : ->
            console.log 'clickUndoIcon'
            #temp
            ###
            require [ 'component/stackrun/main' ], ( stackrun_main ) ->
                stackrun_main.loadModule()
            ###

        clickRedoIcon : ->
            console.log 'clickRedoIcon'
            #temp
            ###
            require [ 'component/sgrule/main' ], ( sgrule_main ) ->
                sgrule_main.loadModule()
            ###

        clickExportPngIcon : ->
            console.log 'clickExportPngIcon'
            this.trigger 'TOOLBAR_EXPORT_PNG_CLICK', MC.canvas_data

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
            modal MC.template.exportpng {"title":"Export PNG", "confirm":"Download", "color":"blue" }, false
            if base64_image
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

            target = $( '#main-toolbar' )
            $('#btn-confirm').on 'click', { target : this }, (event) ->
                #me.trigger 'TOOLBAR_STOP_CLICK', MC.canvas_data.region, MC.canvas_data.id, MC.canvas_data.name
                ide_event.trigger ide_event.STOP_APP, MC.canvas_data.region, MC.canvas_data.id, MC.canvas_data.name
                modal.close()

        clickStartApp : (event) ->
            me = this
            console.log 'click run app'

            target = $( '#main-toolbar' )
            $('#btn-confirm').on 'click', { target : this }, (event) ->
                #me.trigger 'TOOLBAR_START_CLICK', MC.canvas_data.region, MC.canvas_data.id, MC.canvas_data.name
                ide_event.trigger ide_event.START_APP, MC.canvas_data.region, MC.canvas_data.id, MC.canvas_data.name
                modal.close()

        clickTerminateApp : (event) ->
            me = this

            console.log 'click terminate app'

            target = $( '#main-toolbar' )
            $('#btn-confirm').on 'click', { target : this }, (event) ->
                #me.trigger 'TOOLBAR_TERMINATE_CLICK', MC.canvas_data.region, MC.canvas_data.id, MC.canvas_data.name
                ide_event.trigger ide_event.TERMINATE_APP, MC.canvas_data.region, MC.canvas_data.id, MC.canvas_data.name
                modal.close()

    }

    return ToolbarView

