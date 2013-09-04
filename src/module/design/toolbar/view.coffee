#############################
#  View(UI logic) for design/toolbar
#############################

define [ 'MC', 'event',
         'i18n!/nls/lang.js',
         'UI.zeroclipboard',
         'backbone', 'jquery', 'handlebars',
         'UI.selectbox', 'UI.notification'
], ( MC, ide_event, lang, zeroclipboard ) ->

    ToolbarView = Backbone.View.extend {

        el         : document

        stack_tmpl : Handlebars.compile $( '#toolbar-stack-tmpl' ).html()
        app_tmpl   : Handlebars.compile $( '#toolbar-app-tmpl' ).html()

        events     :
            ### env:dev ###
            #json
            'click #toolbar-jsondiff'       : 'clickOpenJSONDiff'
            'click #toolbar-jsonview'       : 'clickOpenJSONView'
            #line style
            'click #toolbar-straight'       : 'clickLineStyleStraight'
            'click #toolbar-elbow'          : 'clickLineStyleElbow'
            'click #toolbar-bezier-q'       : 'clickLineStyleBezierQ'
            'click #toolbar-bezier-qt'      : 'clickLineStyleBezierQT'
            ### env:dev:end ###

            'click #toolbar-run'            : 'clickRunIcon'
            'click .icon-save'              : 'clickSaveIcon'
            'click #toolbar-duplicate'      : 'clickDuplicateIcon'
            'click #toolbar-delete'         : 'clickDeleteIcon'
            'click #toolbar-new'            : 'clickNewStackIcon'
            'click .icon-zoom-in'           : 'clickZoomInIcon'
            'click .icon-zoom-out'          : 'clickZoomOutIcon'
            'click .icon-undo'              : 'clickUndoIcon'
            'click .icon-redo'              : 'clickRedoIcon'
            'click #toolbar-export-png'     : 'clickExportPngIcon'
            'click #toolbar-export-json'    : 'clickExportJSONIcon'
            'click #toolbar-stop-app'       : 'clickStopApp'
            'click #toolbar-start-app'      : 'clickStartApp'
            'click #toolbar-terminate-app'  : 'clickTerminateApp'
            'click .icon-refresh'           : 'clickRefreshApp'

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
            ### env:dev ###
            zeroclipboard.copy $( '#toolbar-jsoncopy' )
            ### env:dev:end ###

            # add by song
            if !$('#phantom-frame')[0]
                $( document.body ).append '<iframe id="phantom-frame" src="' + MC.SAVEPNG_URL + 'proxy.html" style="display:none;"></iframe>'

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

            # check credential
            if $.cookie('has_cred') isnt 'true'
                modal.close()
                console.log 'show credential setting dialog'
                require [ 'component/awscredential/main' ], ( awscredential_main ) -> awscredential_main.loadModule()

            else
                # set total fee
                cost = MC.aws.aws.getCost MC.canvas_data
                $('#label-total-fee').find("b").text("$#{cost.total_fee}")

                target = $( '#main-toolbar' )
                $('#btn-confirm').on 'click', { target : this }, (event) ->
                    console.log 'clickRunIcon'

                    app_name = $('.modal-input-value').val()

                    #check app name
                    if not app_name
                        notification 'warning', lang.ide.PROP_MSG_WARN_NO_APP_NAME
                        return

                    if not MC.validate 'awsName', app_name
                        notification 'warning', lang.ide.PROP_MSG_WARN_INVALID_APP_NAME
                        return

                    if not MC.aws.aws.checkAppName app_name
                        notification 'warning', lang.ide.PROP_MSG_WARN_REPEATED_APP_NAME
                        return


                    modal.close()

                    # check change and save stack
                    ori_data = MC.canvas_property.original_json
                    new_data = JSON.stringify( MC.canvas_data )
                    id = MC.canvas_data.id
                    if ori_data != new_data or id.indexOf('stack-') isnt 0
                        ide_event.trigger ide_event.SAVE_STACK, MC.canvas.layout.save()

                    # hold on 0.5 second for data update
                    setTimeout () ->
                        me.trigger 'TOOLBAR_RUN_CLICK', app_name, MC.canvas_data
                        MC.data.app_list[MC.canvas_data.region].push app_name
                    , 500

            true

        clickSaveIcon : ->
            console.log 'clickSaveIcon'

            name = MC.canvas_data.name
            id = MC.canvas_data.id

            if not name
                notification 'warning', lang.ide.PROP_MSG_WARN_NO_STACK_NAME

            else if name.indexOf(' ') >= 0
                notification 'warning', 'Stack name contains white space.'

            else if not MC.aws.aws.checkStackName id, name
                #notification 'warning', lang.ide.PROP_MSG_WARN_REPEATED_STACK_NAME
                #show modal to re-input stack name
                template = MC.template.modalReinputStackName {
                    stack_name : name
                }

                modal template, false
                $('#rename-confirm').click () ->
                    new_name = $('#new-stack-name').val()
                    console.log 'save stack new name:' + new_name

                    if MC.aws.aws.checkStackName id, new_name
                        modal.close()

                        MC.canvas_data.name = new_name

                        ide_event.trigger ide_event.SAVE_STACK, MC.canvas.layout.save()
                        true

            else
                MC.canvas_data.name = name
                ide_event.trigger ide_event.SAVE_STACK, MC.canvas.layout.save()

            true

        clickDuplicateIcon : (event) ->
            name     = MC.canvas_data.name

            # set default name
            new_name = MC.aws.aws.getDuplicateName(name)
            $('#modal-input-value').val(new_name)

            $('#btn-confirm').on 'click', { target : this }, (event) ->
                console.log 'toolbar duplicate stack'
                new_name = $('#modal-input-value').val()

                #check duplicate stack name
                if not new_name
                    notification 'warning', lang.ide.PROP_MSG_WARN_NO_STACK_NAME
                else if new_name.indexOf(' ') >= 0
                    notification 'warning', 'Stack name contains white space.'
                else if not MC.aws.aws.checkStackName null, new_name
                    notification 'warning', lang.ide.PROP_MSG_WARN_REPEATED_STACK_NAME
                else
                    modal.close()

                    region  = MC.canvas_data.region
                    id      = MC.canvas_data.id
                    name    = MC.canvas_data.name

                    # check change and save stack
                    ori_data = MC.canvas_property.original_json
                    new_data = JSON.stringify( MC.canvas.layout.save() )
                    if ori_data != new_data or id.indexOf('stack-') isnt 0
                        ide_event.trigger ide_event.SAVE_STACK, MC.canvas.layout.save()

                    setTimeout () ->
                        ide_event.trigger ide_event.DUPLICATE_STACK, MC.canvas_data.region, MC.canvas_data.id, new_name, MC.canvas_data.name
                    , 500

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

            this.trigger 'TOOLBAR_ZOOM_IN'

        clickZoomOutIcon : ( event )->
            console.log 'clickZoomOutIcon'

            if $( event.currentTarget ).hasClass("disabled")
                return false

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
            file_content = JSON.stringify MC.canvas.layout.save()
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

            # check credential
            if $.cookie('has_cred') isnt 'true'
                modal.close()
                console.log 'show credential setting dialog'
                require [ 'component/awscredential/main' ], ( awscredential_main ) -> awscredential_main.loadModule()

            else
                target = $( '#main-toolbar' )
                $('#btn-confirm').on 'click', { target : this }, (event) ->
                    #me.trigger 'TOOLBAR_STOP_CLICK', MC.canvas_data.region, MC.canvas_data.id, MC.canvas_data.name
                    ide_event.trigger ide_event.STOP_APP, MC.canvas_data.region, MC.canvas_data.id, MC.canvas_data.name
                    modal.close()

        clickStartApp : (event) ->
            me = this
            console.log 'click run app'

            # check credential
            if $.cookie('has_cred') isnt 'true'
                modal.close()
                console.log 'show credential setting dialog'
                require [ 'component/awscredential/main' ], ( awscredential_main ) -> awscredential_main.loadModule()

            else
                target = $( '#main-toolbar' )
                $('#btn-confirm').on 'click', { target : this }, (event) ->
                    #me.trigger 'TOOLBAR_START_CLICK', MC.canvas_data.region, MC.canvas_data.id, MC.canvas_data.name
                    ide_event.trigger ide_event.START_APP, MC.canvas_data.region, MC.canvas_data.id, MC.canvas_data.name
                    modal.close()

        clickTerminateApp : (event) ->
            me = this

            console.log 'click terminate app'

            # check credential
            if $.cookie('has_cred') isnt 'true'
                modal.close()
                console.log 'show credential setting dialog'
                require [ 'component/awscredential/main' ], ( awscredential_main ) -> awscredential_main.loadModule()

            else
                target = $( '#main-toolbar' )
                $('#btn-confirm').on 'click', { target : this }, (event) ->
                    #me.trigger 'TOOLBAR_TERMINATE_CLICK', MC.canvas_data.region, MC.canvas_data.id, MC.canvas_data.name
                    ide_event.trigger ide_event.TERMINATE_APP, MC.canvas_data.region, MC.canvas_data.id, MC.canvas_data.name
                    modal.close()


        clickLineStyleStraight  : (event) ->
            MC.canvas_property.LINE_STYLE = 1
            ide_event.trigger ide_event.REDRAW_SG_LINE
            null

        clickLineStyleElbow     : (event) ->
            MC.canvas_property.LINE_STYLE = 0
            ide_event.trigger ide_event.REDRAW_SG_LINE
            null

        clickLineStyleBezierQ   : (event) ->
            MC.canvas_property.LINE_STYLE = 2
            ide_event.trigger ide_event.REDRAW_SG_LINE
            null

        clickLineStyleBezierQT  : (event) ->
            MC.canvas_property.LINE_STYLE = 3
            ide_event.trigger ide_event.REDRAW_SG_LINE
            null

        clickRefreshApp         : (event) ->
            console.log 'toolbar clickRefreshApp'
            ide_event.trigger ide_event.UPDATE_APP_RESOURCE, MC.canvas_data.region, MC.canvas_data.id

    }

    return ToolbarView

